---
date: 2018-10-27T00:00:00Z
title: Setup a HP printer/scanner with CUPS and SANE on Arch Linux
tags:
  - Printer
---

This example worked with HP LaserJet MFP M130nw (2018).

<!--more-->

Install `cups`, `sane` and `hplip`

	pacman -S cups sane hplip

Enable and starts `cups-browsed`

	systemctl enable --now cups-browsed.service

With the IP address of your HP printer/scanner, query its uri's

	hp-makeuri <printer-ip-address>
	...
	CUPS URI: hp:/net/HP_LaserJet_MFP_M129-M134?ip=...
	SANE URI: hpaio:/net/HP_LaserJet_MFP_M129-M134?ip=...
	HP Fax URI: hpfax:/net/HP_LaserJet_MFP_M129-M134?ip=...
	...

In the CUPS interface (http://localhost:631), configure a new printer:

  1. Go to *Administration* (http://localhost:631/admin),
  2. Click *Add Printer*,
  3. Select *AppSocket/HP JetDirect* and click *Continue*,
  4. Enter the CUPS URI from above (hp:/...) and click *Continue*,
  5. Enter details for the printer and check the *Share printer* option,
  6. Select a driver under make HP (name should match URI),
  7. Set defaults.

Check that the printer works and can be used by other computers on the network.

Install HP proprietary plugins (source https://askubuntu.com/q/153746/139673)

	hp-plugin

Check that SANE finds the scanner

	scanimage -L
	device `hpaio:/net/HP_LaserJet_MFP_M129-M134?ip=...' is a Hewlett-Packard HP_LaserJet_MFP_M129-M134 all-in-one

Test the scanner (see output of `scanimage --help` for options)

	scanimage --device-name 'hpaio:/net/HP_LaserJet_MFP_M129-M134?ip=...' --mode Gray --resolution 150 --format png --progress > test.png

## Troubleshooting

So far it seems it is not possible to share the scanning capability over the
network (sane blocks share /net scanners).
