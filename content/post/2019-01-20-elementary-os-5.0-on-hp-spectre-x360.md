---
title: "Elementary Os 5.0 on HP spectre X360"
date: 2019-01-20T00:00:00+01:00
tags:
  - GNU/Linux Install
  - Elementary OS
  - HP spectre X360
  - UEFI
---

Works well.

<!--more-->

plug usb

boot

esc esc esc esc

BIOS Setup > System Configuration > System Power Scheme SET TO [Balance]

save and exit

esc esc esc esc

boot from usb (UEFI)

install elementary OS

The account and LVM + encrypt password will be in the layout you choose.

shutdown

remove usb

boot

AppCenter > Updates

install nvidia and intel drivers

install OS updates

restart

System Settings > Mouse & Touchpad > Pointer speed: maximum

System Settings > User Accounts > Guest Session > unlock > disable guest account

NVIDIA X Server Settings > PRIME Profile > Intel (Power Saving Mode)

restart

	gsettings set org.gnome.desktop.interface scaling-factor 3

System Settings > Desktop > Dock > Icon size: Large

System Settings > Power > Automatically adjust brightness
System Settings > Power > Turn off display when inactive for: 15 min
System Settings > Power > Power button: Suspend
System Settings > Power > On Battery > Sleep when inactive for: 30 min
System Settings > Power > Plugged In > Sleep when inactive for: Never

Battery > Show Percentage

restart

AppCenter > install Firefox

... xinput disable 11 for writing

### Disable Bluetooth

rfkill block 0 # kill it
sudo systemctl disable --now bluetooth # hide it

### Disable single click in Files

Install dconf

dconf > io > elementary > ... > preferences > single click : toggle
