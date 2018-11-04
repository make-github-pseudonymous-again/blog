---
date: 2018-04-05T00:00:00Z
title: Host your files at home with Nextcloud
---

Ever wanted to get rid of your dependency on Dropbox and Google Drive?

<!--more-->

> More details [here](https://wiki.archlinux.org/index.php/Nextcloud).

[Install and configure NGiИX](/2018/04/10/install-and-configure-nginx-with-https-on-arch-linux/).

### [PostgreSQL](https://wiki.archlinux.org/index.php/PostgreSQL)

Install the relevant packages:

	sudo pacman -S postgresql

Init the database:

	sudo -u postgres -i
	[postgres]$ initdb --locale $LANG -E UTF8 -D '/var/lib/postgres/data'
	[postgres]$ exit

Enable and start the service:

	sudo systemctl enable --now postgresql

Create a user and a database:

	sudo -u postgres createuser -h localhost -P nextcloud
	sudo -u postgres createdb -O nextcloud nextcloud

### [PHP](https://wiki.archlinux.org/index.php/PHP)

Install relevant packages:

	pacman -S php php-pgsql php-intl php-gd php-fpm

Edit the following lines in `/etc/php/php.ini`:

	data.timezone = Europe/Brussels
	extension=gd
	extension=iconv
	extension=pdo_pgsql
	extension=pgsql

Do not forget to configure `php-fpm`

Uncomment `env[PATH] = /usr/local/bin:/usr/bin:/bin` in `/etc/php/php-fpm.d/www.conf`

	systemctl enable --now php-fpm

### NGiИX

	mkdir /etc/nginx/conf.d

	# /etc/nginx/nginx.conf
	http {
		...
		...
		server_names_hash_bucket_size 64;
		include conf.d/*.conf;
	}

Create a server block [as here
(webroot)](https://docs.nextcloud.com/server/13/admin_manual/installation/nginx.html)
in `/etc/nginx/conf.d/nextcloud.conf`.

Use `/usr/share/webapps/nextcloud` instead of `/var/www/nextcloud`. Change the
upstream hook.

	upstream php-handler {
	   server unix:/run/php-fpm/php-fpm.sock;
	}

Then restart the service:

	systemctl restart nginx

### Configure Nextcloud

	mkdir -p /usr/share/webapps/nextcloud/{data,apps2}
	chown http:http /usr/share/webapps/nextcloud/{data,apps2}
	chmod 700 /usr/share/webapps/nextcloud/{data,apps2}

	# /etc/webapps/nextcloud/config/config.php
	'apps_paths' =>
	  array (
		0 =>
		array (
		  'path' => '/usr/share/webapps/nextcloud/apps',
		  'url' => '/apps',
		  'writable' => false,
		),
		1 =>
		array (
		  'path' => '/usr/share/webapps/nextcloud/apps2',
		  'url' => '/apps2',
		  'writable' => true,
		),
	  ),
	  'datadirectory' => '/usr/share/webapps/nextcloud/data'
