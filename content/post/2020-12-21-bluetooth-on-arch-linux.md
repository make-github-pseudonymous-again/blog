---
title: Bluetooth on Arch Linux
date: 2020-12-21T15:52:20+01:00
tags:
  - Automation
  - Crashes
  - Bluetooth
  - Wireless
  - Pulseaudio
  - Audio
---

Install software

	pacman -S bluez bluez-utils


If you want bluetooth to power on the chip as soon as `bluetooth.service` is
running

	/etc/bluetooth/main.conf

	[Policy]
	AutoEnable=true


Enable and start the bluetooth service

	systemctl enable --now bluetooth


Connect bluetooth headset/speaker.


	pacman -S pulseaudio-bluetooth
	systemctl --user restart pulseaudio
	bluetoothctl agent on
	bluetoothctl power on
	bluetoothctl scan on
	pair ...
	connect ...
