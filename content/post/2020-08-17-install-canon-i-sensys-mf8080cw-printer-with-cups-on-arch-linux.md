---
date: 2020-08-17T00:00:00Z
title: Setup Canon i-SENSYS MF8080Cw printer with CUPS on Arch Linux
tags:
  - Printer
  - DNSSD
  - CUPS
---

Configuration:

  - Printer: Canon i-SENSYS MF8080Cw
  - Driver: Canon MF8000C Series UFRII LT
  - Discovery: DNSSD

<!--more-->

Install `cups`, `nss-mdns`, and `cnrdrvcups-lb-bin`

	trizen -S cups nss-mdns cnrdrvcups-lb-bin

Configure `nss-mdns` in `/etc/nsswitch.conf`

	# Name Service Switch configuration file.
	# See nsswitch.conf(5) for details.

	passwd: files mymachines systemd
	group: files mymachines systemd
	shadow: files

	publickey: files

	hosts: files mymachines myhostname mdns_minimal [NOTFOUND=return] resolve [!UNAVAIL=return] dns
	networks: files

	protocols: files
	services: files
	ethers: files
	rpc: files

	netgroup: files

Enable and start `avahi-daemon` ([more info on the wiki](https://wiki.archlinux.org/index.php/Avahi#Hostname_resolution))

	systemctl enable --now avahi-daemon.service

Enable and start `cups-browsed`

	systemctl enable --now cups-browsed.service

Restart `org.cups.cupsd`

	systemctl restart org.cups.cupsd.service

Query the printer's URI

	lpinfo --include-schemes dnssd -v
	...
	dnssd://Canon%20MF8000C._printer._tcp.local
	...

In the CUPS interface (http://localhost:631), configure a new printer:

  1. Go to *Administration* (http://localhost:631/admin),
  2. Click *Add Printer*,
  3. Select the printer in *Discovered Network Printers* and click *Continue*,
  4. Check that the URI matches the one found above (`dnssd:/...`) and click *Continue*,
  5. Enter details for the printer,
  6. Select the driver under make Canon (Canon MF8000C Series UFRII LT),
  7. Set defaults.

Check that the printer works.

## Troubleshooting

So far it seems this printer does not support 2-sided printing. The only
solution is manual page flipping which is tedious.
