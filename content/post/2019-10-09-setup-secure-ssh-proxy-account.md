---
title: "Setup Secure SSH Proxy Account"
date: 2019-10-09T11:55:57+02:00
tags:
  - Security
  - SSH
  - Proxy
---

No need to enable full login shell if the only intended usage is proxying.

<!--more-->

Create user

	useradd -m -s /sbin/nologin proxy


Setup `ssh`

	cd /home/proxy
	mkdir .ssh
	touch .ssh/authorized_keys
	chown -R proxy:proxy .ssh
	chmod 700 .ssh
	chmod 640 .ssh/authorized_keys


Set further restrictions if necessary. In `/etc/ssh/sshd_config`, add

	Match User proxy
	        X11Forwarding no


Add some user key

	echo "some SSH key" >> .ssh/authorized_keys


Restart `sshd`

	systemctl restart sshd


To start a SOCKSv5 proxy on localhost:8080, execute

	ssh -D 8080 proxy@proxyhost -N

and leave it running.
