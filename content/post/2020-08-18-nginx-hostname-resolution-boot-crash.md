---
date: 2020-08-18T00:00:00Z
title: NGiИX hostname resolution boot crash
tags:
  - Automation
  - NGiИX
  - Crashes
---

NGiИX crashes on boot when proxying via hostname resolution.

<!--more-->

Unfortunately `/etc/hosts` does not seem to be accessible when `nginx.service`
starts the first time with the default Arch linux configuration.
This results in the following crash report:

	 systemctl status nginx
	 ● nginx.service - A high performance web server and a reverse proxy server
	      Loaded: loaded (/usr/lib/systemd/system/nginx.service; enabled; vendor preset: disabled)
	      Active: failed (Result: exit-code) since Tue 2020-08-18 11:02:22 CEST; 7min ago
	     Process: 317 ExecStart=/usr/bin/nginx -g pid /run/nginx.pid; error_log stderr; (code=exited, status=1/FAILURE)

	 Aug 18 11:02:18 H systemd[1]: Starting A high performance web server and a reverse proxy server...
	 Aug 18 11:02:22 H nginx[317]: 2020/08/18 11:02:20 [emerg] 317#317: host not found in upstream "example.local" in /etc/nginx/conf.d/example.com.conf:13
	 Aug 18 11:02:22 H systemd[1]: nginx.service: Control process exited, code=exited, status=1/FAILURE
	 Aug 18 11:02:22 H systemd[1]: nginx.service: Failed with result 'exit-code'.
	 Aug 18 11:02:22 H systemd[1]: Failed to start A high performance web server and a reverse proxy server.

Restarting `nginx.service` goes through without a problem

	 systemctl restart nginx
	 systemctl status nginx
	 ● nginx.service - A high performance web server and a reverse proxy server
	      Loaded: loaded (/usr/lib/systemd/system/nginx.service; enabled; vendor preset: disabled)
	      Active: active (running) since Tue 2020-08-18 11:11:34 CEST; 5s ago
	     Process: 1909 ExecStart=/usr/bin/nginx -g pid /run/nginx.pid; error_log stderr; (code=exited, status=0/SUCCESS)
	    Main PID: 1910 (nginx)
	       Tasks: 2 (limit: 4699)
	      Memory: 6.2M
	      CGroup: /system.slice/nginx.service
		      ├─1910 nginx: master process /usr/bin/nginx -g pid /run/nginx.pid; error_log stderr;
		      └─1911 nginx: worker process

	 Aug 18 11:11:34 H systemd[1]: Starting A high performance web server and a reverse proxy server...
	 Aug 18 11:11:34 H systemd[1]: Started A high performance web server and a reverse proxy server.

Some occurrences in the wild:

  - https://sandro-keil.de/blog/let-nginx-start-if-upstream-host-is-unavailable-or-down
  - https://stackoverflow.com/questions/50248522/nginx-will-not-start-with-host-not-found-in-upstream

### Robust automated solution in general (without custom DNS resolver)

Setup `nginx.service` to restart properly and eventually not crash.


	 # /usr/lib/systemd/system/nginx.service
	[Unit]
	Description=A high performance web server and a reverse proxy server (edited)
	After=network.target network-online.target nss-lookup.target

	# Prevents more that 5 starts within 10 seconds
	StartLimitIntervalSec=10
	StartLimitBurst=5

	[Service]
	Type=forking
	PIDFile=/run/nginx.pid
	PrivateDevices=yes
	SyslogLevel=err

	ExecStart=/usr/bin/nginx -g 'pid /run/nginx.pid; error_log stderr;'
	ExecReload=/usr/bin/nginx -s reload
	KillMode=mixed

	# Restart on failure after 15 seconds
	Restart=on-failure
	RestartSec=15

	[Install]
	WantedBy=multi-user.target

See
[systemd.service](https://www.freedesktop.org/software/systemd/man/systemd.service.html)
for `Restart=on-failure` and `RestartSec=15`,
and
[systemd.unit](https://www.freedesktop.org/software/systemd/man/systemd.unit.html)
for `StartLimitIntervalSec=10` and `StartLimitBurst=5`.

### When the problem is caused by local hostnames

Two solutions are suggested
[on the Arch wiki](https://wiki.archlinux.org/index.php/Network_configuration#Local_network_hostname_resolution):

  - Use a local DNS server to resolve local hostnames.
  - Use a Zero-configuration networking service (NetBIOS or mDNS).

This should broadcast the host name in `/etc/hostname`.
See
[this serverfault question](https://serverfault.com/questions/268401/configure-zeroconf-to-broadcast-multiple-names/986437)
to assign multiple hostnames to a single machine.
