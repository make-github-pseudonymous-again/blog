---
title: "Setup Secure SSH Tunnel Account"
date: 2019-10-09T11:55:57+02:00
tags:
  - Security
  - SSH
  - Tunnel
---

No need to enable full login shell if the only intended usage is tunneling.

<!--more-->

Create user

	useradd -m -s /sbin/nologin tunnel


Setup `ssh`

	cd /home/tunnel
	mkdir .ssh
	touch .ssh/authorized_keys
	chown -R tunnel:tunnel .ssh
	chmod 700 .ssh
	chmod 640 .ssh/authorized_keys


Set further restrictions if necessary. In `/etc/ssh/sshd_config`, add

	Match User tunnel
	        PermitOpen 5.6.7.8:22
	        X11Forwarding no


Add some user key

	echo "some SSH key" >> .ssh/authorized_keys


Restart `sshd`

	systemctl restart sshd


On your work station open two terminals.

On the first one,

	ssh tunnel@tunnelhost -L 1234:5.6.7.8:22 -N

On the second,

	ssh username@localhost -p 1234

Replace 1234 in both commands with any unused port on your work machine and
replace `username` with your username on 5.6.7.8.
