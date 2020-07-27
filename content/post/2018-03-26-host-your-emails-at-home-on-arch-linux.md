---
date: 2018-03-26T00:00:00Z
title: Host your e-mails at home on Arch Linux
---

A tutorial explaining how to host your electronic mail at home on Arch Linux.

<!--more-->

## Get a domain name.

## Fixed IP address or dynamic DNS.

## Install a SMTP server

### Install a `MySQL`-type database system

Detailed instructions [here](https://wiki.archlinux.org/index.php/MySQL).

We choose `MariaDB`.

#### Install `MariaDB`

Detailed instructions [here](https://wiki.archlinux.org/index.php/MariaDB).

```sh
pacman -S mariadb
```

```sh
mysql_install_db --user=mysql --basedir=/usr --datadir=/var/lib/mysql
systemctl enable --now mariadb
mysql_secure_installation
```

### Install `postfix`

Detailed instructions [here](https://wiki.archlinux.org/index.php/Postfix).

```sh
pacman -S postfix
```

#### Make it secure

See
https://wiki.archlinux.org/index.php/Postfix#TLS
and
https://weakdh.org/sysadmin.html
.

Add the following lines to `/etc/postfix/main.cf`:

```sh
smtp_tls_security_level = encrypt
smtpd_tls_exclude_ciphers = aNULL, eNULL, EXPORT, DES, RC4, MD5, PSK, aECDH, EDH-DSS-DES-CBC3-SHA, EDH-RSA-DES-CBC3-SHA, KRB5-DES, CBC3-SHA
smtpd_tls_dh1024_param_file = ${config_directory}/dhparams.pem
```

Execute the following inside /etc/postfix (`postconf -d | grep config_directory`)
```sh
openssl dhparam -out dhparams.pem 2048
```

Create some SSL keys using Let's Encrypt
```sh
pacman -S certbot
```

Add the file

```
# /etc/nginx/conf.d/yourdomain.conf
/

Make sure `yourdomain` points to your WAN IP address, then

	certbot --nginx

Finally,

	ln -s /etc/letsencrypt/live/yourdomain/privkey.pem /etc/ssl/private/vmail.key
	ln -s /etc/letsencrypt/live/yourdomain/fullchain.pem /etc/ssl/private/vmail.crt

#### Enable grey listing

Install `postgrey`

	pacman -S `postgrey`

```
# /etc/postfix/main.cf

smtpd_recipient_restrictions = check_policy_service inet:127.0.0.1:10030
```

	systemctl enable --now postgrey

#### Start it

```sh
systemctl enable --now postfix
```



### Configure

Follow the instructions at
https://wiki.archlinux.org/index.php/Virtual_user_mail_system_with_Postfix,_Dovecot_and_Roundcube#Configuration
.

#### User

	groupadd -g 5000 vmail
	useradd -u 5000 -g vmail -s /usr/bin/nologin -d /home/vmail -m vmail

#### Database

	mysql -u root -p

	CREATE DATABASE postfix_db;
	GRANT ALL ON postfix_db.* TO 'postfix_user'@'localhost' IDENTIFIED BY '<password>';
	FLUSH PRIVILEGES;

#### Dovecot (Part 1)

	openssl dhparam -out /etc/dovecot/dh.pem 4096

```
# /etc/dovecot/dovecot.conf
protocols = imap pop3
auth_mechanisms = plain
passdb {
    driver = sql
    args = /etc/dovecot/dovecot-sql.conf
}
userdb {
    driver = sql
    args = /etc/dovecot/dovecot-sql.conf
}

service auth {
    unix_listener auth-client {
        group = postfix
        mode = 0660
        user = postfix
    }
    user = root
}

mail_home = /home/vmail/%d/%n
mail_location = maildir:~

ssl_cert = </etc/ssl/private/vmail.crt
ssl_key = </etc/ssl/private/vmail.key
ssl_dh = </etc/dovecot/dh.pem
```

```
# /etc/dovecot/dovecot-sql.conf
driver = mysql
connect = host=localhost dbname=postfix_db user=postfix_user password=hunter2
# It is highly recommended to not use deprecated MD5-CRYPT. Read more at http://wiki2.dovecot.org/Authentication/PasswordSchemes
default_pass_scheme = SHA512-CRYPT
# Get the mailbox
user_query = SELECT '/home/vmail/%d/%n' as home, 'maildir:/home/vmail/%d/%n' as mail, 5000 AS uid, 5000 AS gid, concat('dirsize:storage=',  quota) AS quota FROM mailbox WHERE username = '%u' AND active = '1'
# Get the password
password_query = SELECT username as user, password, '/home/vmail/%d/%n' as userdb_home, 'maildir:/home/vmail/%d/%n' as userdb_mail, 5000 as  userdb_uid, 5000 as userdb_gid FROM mailbox WHERE username = '%u' AND active = '1'
# If using client certificates for authentication, comment the above and uncomment the following
#password_query = SELECT null AS password, ‘%u’ AS user
```

##### Postfix Admin (with `nginx` already configured)

	pacman -S postfixadmin php-fpm php-imap

> **NB**:
> This creates the `postfixadmin` user on install.
> No manual creation need.
> Check with `less /etc/passwd`.

```
# /etc/webapps/postfixadmin/config.local.php
<?php

$CONF['configured'] = true;
// correspond to dovecot maildir path /home/vmail/%d/%u
$CONF['domain_path'] = 'YES';
$CONF['domain_in_mailbox'] = 'NO';
$CONF['database_type'] = 'mysqli';
$CONF['database_host'] = 'localhost';
$CONF['database_user'] = 'postfix_user';
$CONF['database_password'] = '<database password for postfix_user>';
$CONF['database_name'] = 'postfix_db';

$CONF['encrypt'] = 'dovecot:SHA512-CRYPT';

$CONF['default_aliases'] = array (
    'abuse' => 'abuse@example.org',
    'hostmaster' => 'hostmaster@example.org',
    'postmaster' => 'postmaster@example.org',
    'webmaster' => 'webmaster@example.org'
);

$CONF['vacation_domain'] = 'autoreply.example.org';

$CONF['footer_text'] = 'Return to example.org';
$CONF['footer_link'] = 'https://example.org';
```

```
# /etc/php/php-fpm.d/postfixadmin.conf
[postfixadmin]
user = postfixadmin
group = postfixadmin
listen = /run/postfixadmin/postfixadmin.sock
listen.owner = http
listen.group = http
pm = ondemand
pm.max_children = 4
```
Uncomment the `imap` and `mysqli` extensions in `/etc/php/php.ini`.

	systemctl enable --now php-fpm


```
#/etc/nginx/conf.d/postfixadmin.conf

server {
  listen 8081;
  server_name postfixadmin;
  root /usr/share/webapps/postfixadmin/public/;
  index index.php;
  charset utf-8;

  access_log /var/log/nginx/postfixadmin-access.log;
  error_log /var/log/nginx/postfixadmin-error.log;

  location / {
    try_files $uri $uri/ index.php;
  }

  location ~* \.php$ {
    fastcgi_split_path_info ^(.+\.php)(/.+)$;
    include fastcgi_params;
    fastcgi_pass unix:/run/postfixadmin/postfixadmin.sock;
    fastcgi_index index.php;
    include fastcgi_params;
    fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
    fastcgi_buffer_size 16k;
    fastcgi_buffers 4 16k;
  }
}
```

Include this new config file to `/etc/nginx/nginx.conf`, then

	systemctl restart nginx

Finally, navigate to http://127.0.0.1:8081/setup.php to finish the
setup. Generate your setup password hash at the bottom of the page once it is
done. Write the hash to the config file

/etc/webapps/postfixadmin/config.local.php

$CONF['setup_password'] = 'yourhashhere';

Now you can create a superadmin account at http://127.0.0.1:8081/setup.php
