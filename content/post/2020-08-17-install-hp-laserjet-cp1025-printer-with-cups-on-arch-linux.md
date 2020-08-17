---
date: 2020-08-17T00:00:00Z
title: Setup HP LaserJet CP1025 printer with CUPS on Arch Linux
tags:
  - Printer
  - CUPS
  - hplip
---

Configuration:

  - Printer: HP LaserJet CP1025
  - Driver: HP LaserJet cp1025, hpcups 3.20.6, requires proprietary plugin (color)
  - Discovery: none (USB)

<!--more-->

Install `cups`, `hplip`, and `hplip-plugin`

	trizen -S cups hplip hplip-plugin

Enable and start `cups-browsed`

	systemctl enable --now cups-browsed.service

Find the USB bus and device ID used by the printer

	lsusb
	...
	Bus 003 Device 011: ID 03f0:c202 Hewlett-Packard
	...

With the IP address of your HP printer/scanner, query its URI

	hp-makeuri <Bus>:<Device>
	...
	CUPS URI: hp:/usb/HP_LaserJet_CP1025?serial=...
	...

In the CUPS interface (http://localhost:631), configure a new printer:

  1. Go to *Administration* (http://localhost:631/admin),
  2. Click *Add Printer*,
  3. Select *AppSocket/HP JetDirect* and click *Continue*,
  4. Enter the URI from above (`hp:/...`) and click *Continue*,
  5. Enter details for the printer,
  6. Select a driver under make HP (name should match URI),
  7. Set defaults.

Check that the printer works.
