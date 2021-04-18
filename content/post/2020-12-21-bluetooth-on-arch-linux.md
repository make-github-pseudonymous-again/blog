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
	bluetoothctl pair ...
	bluetoothctl connect ...

> Tip: Instead of typing `bluetoothctl` for each command you can start a REPL
> by calling `bluetoothctl` without arguments.

## Troubleshoot

If you do not bridge `pulseaudio` and `bluetooth` you may get one of the
following:

	Failed to connect: org.bluez.Error.NotReady
	Failed to connect: org.bluez.Error.Failed
