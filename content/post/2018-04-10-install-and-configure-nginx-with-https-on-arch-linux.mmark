---
date: 2018-04-10T00:00:00Z
title: Install and configure NGiИX with HTTPS on Arch Linux
---

NGiИX is useful to proxy all sorts of web servers.

<!--more-->

> All the commands and edits must be run and made as root.

### NGiИX installation

Install the `nginx` package:

	pacman -S nginx

### Domain names configuration

Configure your domains (`/etc/nginx/nginx.conf`). Here is an example for the
domain name `my.example.com`. Repeat the server block for each domain you want
to configure.

```
#user html;
worker_processes  1;

#error_log  logs/error.log;
#error_log  logs/error.log  notice;
#error_log  logs/error.log  info;

#pid        logs/nginx.pid;


events {
    worker_connections  1024;
}


http {
    include       mime.types;
    default_type  application/octet-stream;

    sendfile        on;

    keepalive_timeout  65;

    server_tokens off;
    map $http_upgrade $connection_upgrade {
    	default upgrade;
        '' close;
    }

    server {
         listen 80;
         listen [::]:80;
         server_name my.example.com;
         root /etc/nginx/my.example.com;
    }

	... repeat for each domain

}
```

### DNS

Make sure your domain name is mapped.

### NAT (HTTP)

Make sure port 80 is mapped

### Let's Encrypt

Install the needed packages:

	pacman -S certbot certbot-nginx

Run certbot and follow the instructions:

	certbot --nginx

Generate [a strong DH group](https://weakdh.org/sysadmin.html)

	openssl dhparam -out /etc/nginx/dhparams.pem 2048

Configure NGiИX to use strong ciphers. Replace `localappportfordomain1` by the
local port of your application.

```
...

http {
	...
	server {
		 listen 80;
		 listen [::]:80;
		 server_name my.example.com;
		 root /etc/nginx/my.example.com;
		 location / {
		   return 301 https://$host$request_uri;
		 }

	 }

	server {
	   listen 443;
	   listen [::]:443;
	   server_name my.example.com;
	   ssl on;
	   ssl_certificate /etc/letsencrypt/live/my.example.com/fullchain.pem;
	   ssl_certificate_key /etc/letsencrypt/live/my.example.com/privkey.pem;
	   ssl_trusted_certificate /etc/letsencrypt/live/my.example.com/chain.pem;
	   ssl_stapling on;
	   ssl_session_cache shared:SSL:10m;
	   ssl_session_timeout 5m;
	   ssl_prefer_server_ciphers on;
	   ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
	   ssl_ciphers 'ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-DSS-AES128-GCM-SHA256:kEDH+AESGCM:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA:ECDHE-ECDSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-DSS-AES128-SHA256:DHE-RSA-AES256-SHA256:DHE-DSS-AES256-SHA:DHE-RSA-AES256-SHA:AES128-GCM-SHA256:AES256-GCM-SHA384:AES128-SHA256:AES256-SHA256:AES128-SHA:AES256-SHA:AES:CAMELLIA:DES-CBC3-SHA:!aNULL:!eNULL:!EXPORT:!DES:!RC4:!MD5:!PSK:!aECDH:!EDH-DSS-DES-CBC3-SHA:!EDH-RSA-DES-CBC3-SHA:!KRB5-DES-CBC3-SHA';
	   ssl_dhparam /etc/nginx/dhparams.pem;
	   add_header Strict-Transport-Security "max-age=31536000;";
	   if ($http_user_agent ~ "MSIE" ) {
		  return 303 https://browser-update.org/update.html;
	   }
	   location / {
		  proxy_pass http://0.0.0.0:localappportfordomain1;
		  proxy_http_version 1.1;
		  proxy_set_header Upgrade $http_upgrade;
		  proxy_set_header Connection $connection_upgrade;
	   }
   }

   ...

}
```

Configure [automatic renewal of the Let's Encrypt certificates](https://wiki.archlinux.org/index.php/Let%E2%80%99s_Encrypt#Automatic_renewal):

```
# file /etc/systemd/system/certbot.service

[Unit]
Description=Let's Encrypt renewal

[Service]
Type=oneshot
ExecStart=/usr/bin/certbot renew --agree-tos
```

Check that the service works:

	systemctl start certbot

Create a timer for the service:

```
# file /etc/systemd/system/certbot.timer

[Unit]
Description=Twice daily renewal of Let's Encrypt's certificates

[Timer]
OnCalendar=0/12:00:00
RandomizedDelaySec=1h
Persistent=true

[Install]
WantedBy=timers.target
```

	systemctl enable --now certbot.timer

### NAT (HTTPS)

Make sure port 443 is mapped.

### Troubleshooting

Should work.
