---
title: Arch Linux on X1 Yoga 4th Gen
date: 2019-11-29T23:11:53+01:00
tags:
  - GNU/Linux Install
  - Arch
  - X1 Yoga 4th Gen
  - UEFI
  - udev
  - systemd
---

This guide will walk you through installing Arch Linux on a Lenovo Thinkpad X1
Yoga 4th Gen.

<!--more-->

# Install

Fire up the machine then

	F1 (Firmware Settings)

	UEFI BIOS Version N2HET40W (1.23)
	UEFI BIOS Date 2019-10-17
	Embedded Controller Version N2HHT27W (1.10)
	ME Firmware Version 12.0.47.1524
	Machine Type Model 20QGS12C00

	CPU Type i7-8665U
	Installed memory 16384MB

	Config > Setup UI ~ Simple Text

	Security > Secure Boot > Disable Secure Boot (toggle switch)

	Security > Password ~ Define passwords and enable all

	Security > Fingerprint ~ Reset Data and Disable

	Security > Internal Device Access ~ Activate tamper detection

	Restart > OS Optimized Defaults ~ Disabled

	Startup > Network Boot ~ NVMe0

	Startup > Option key Display ~ Disabled

	? Config > Network > Wake On LAN ~ Disable
	? Config > Network > Wake On LAN from Dock ~ Disable
	Config > Network > Lenovo Cloud Services ~ Disable
	Config > Power > Sleep State ~ Linux
	Config > Beep and Alarm > Password beep ~ Disable
	Config > Beep and Alarm > Keyboard beep ~ Disable
	Config > USB > Always On USB ~ Disable

	Date/Time ~ Set correct date and time

	F10 (Save and Exit)

With LiveUSB plugged in

	F12 > Select USB key to boot

Use better font

	setfont latarcyrheb-sun32

Follow install guide

	...

# Customize

## Display

Install `vulkan-intel` driver (see [reports](https://vulkan.gpuinfo.org/listreports.php?devicename=Intel(R)%20HD%20Graphics%20620
))

	pacman -S mesa vulkan-intel

Nice setting for boot loader `console-mode max`.

Nice font for vconsole `latarcyrheb-sun32` or `ter-132n` (need install `terminus-font`).

NO need to put `i915` in MODULES in `/etc/mkinitcpio.conf`.

Nice PPI setting: `Xft.dpi: 216` (`192` is OK but small) in `.Xresources` (at max res `3840x2160`).

## Sound

**EDIT**:  Works out of the box with latest updates (firmware/software) as of December 12 2020.

    pacmd list-sinks | \
    grep  '^\s*\(\(\* \)\?index:\|device.description =\)' | \
    sed 's/^\s*\(\(\* \)\?index:\|device.description =\) //g' | \
    sed 's/ <.*>//g' | \
    xargs -L 2 echo
    0 Cannon Point-LP High Definition Audio Controller HDMI3 Output
    1 Cannon Point-LP High Definition Audio Controller HDMI2 Output
    2 Cannon Point-LP High Definition Audio Controller HDMI1 Output
    3 Cannon Point-LP High Definition Audio Controller Speaker + Headphones

See https://bugs.archlinux.org/task/64720

## Keyboard

Use firmware to swap fn and ctrl (`Config > Keyboard/Mouse > Fn and Ctrl Key
swap ~ Enabled`)

Use custom keymap to swap caps lock and enter. See [the
wiki](https://wiki.archlinux.org/index.php/Linux_console/Keyboard_configuration#Creating_a_custom_keymap).

## Lid and Power Button

	# vim /etc/systemd/logind.conf
	[Login]
	...
	HandlePowerKey=suspend
	HandleSuspendKey=suspend
	HandleHibernateKey=suspend
	HandleLidSwitch=suspend
	HandleLidSwitchExternalPower=suspend
	HandleLidSwitchDocked=ignore
	HoldoffTimeoutSec=15s
	...

## WiFi

Works out of the box with

	pacman -S dhcpcd netctl iw dialog wpa_supplicant wireless_tools

## Bluetooth

Install software

	pacman -S bluez bluez-utils

If you want bluetooth to power on the chip as soon as `bluetooth.service` is
running

	/etc/bluetooth/main.conf

	[Policy]
	AutoEnable=true

Enable and start the bluetooth service

	systemctl enable --now bluetooth

### Headset

	pacman -S pulseaudio-bluetooth
	systemctl --user restart pulseaudio

For more, see https://wiki.archlinux.org/index.php/Bluetooth_headset


## Trackpoint

Works out of the box.

## Touchpad

	pacman -S xorg-xinput

### Adjust Sensitivity and Enable Tapping

https://www.reddit.com/r/linuxquestions/comments/45hhep/multiple_mice_how_do_i_change_just_ones/

	# /etc/X11/xorg.conf.d/50-touchpad.conf
	Section "InputClass"
	  Identifier     "Touchpad Speed"
	  MatchProduct   "Touchpad"
	  Option         "Accel Speed" "1.00"
	  Option         "Tapping" "1"
	EndSection


## Touch Screen and Stylus

Works out of the box with

	pacman -S xf86-input-wacom

## Fingerprint Reader

?

## Camera

Works out of the box.

## Microphone

Works out of the box with latest updates (firmware/software) as of December 12 2020.

    pacmd list-sources | \
    grep  '^\s*\(\(\* \)\?index:\|device.description =\)' | \
    sed 's/^\s*\(\(\* \)\?index:\|device.description =\) //g' | \
    sed 's/ <.*>//g' | \
    xargs -L 2 echo
    0 Monitor of Cannon Point-LP High Definition Audio Controller HDMI3 Output
    1 Monitor of Cannon Point-LP High Definition Audio Controller HDMI2 Output
    2 Monitor of Cannon Point-LP High Definition Audio Controller HDMI1 Output
    3 Monitor of Cannon Point-LP High Definition Audio Controller Speaker + Headphones
    4 Cannon Point-LP High Definition Audio Controller Headphones Stereo Microphone
    5 Cannon Point-LP High Definition Audio Controller Digital Microphone


## Speakers

See [the wiki](https://wiki.archlinux.org/index.php/Lenovo_ThinkPad_X1_Yoga_(Gen_4)#Audio).

## Beeper

To disable temporarily

	modprobe -r pcspkr

To disable permanently add

	# /etc/modprobe.d/nobeep.conf
	blacklist pcspkr

See also
https://www.thinkwiki.org/wiki/How_to_disable_the_pc_speaker_(beep!)
and
https://wiki.archlinux.org/index.php/Kernel_module#Blacklisting

## Firmware Updates

fwupd: https://wiki.archlinux.org/index.php/Fwupd

	pacman -S fwupd

To update DB

	fwupdmgr refresh

To check what updates are available

	fwupdmgr get-updates

To update firmware

	fwupdmgr update

See the [wiki](https://wiki.archlinux.org/index.php/Fwupd) for more.

## Automatic screen layout switching

> **TODO** Resolution is wrong when switching back to `default` via `autorandr
> --batch --change`.

Install and configure `autorandr`

	pacman -S autorandr
	... # undock and configure undocked layout
	autorandr --save default
	... # dock and configure docked layout
	autorandr --save docked

Setup udev rule

	# /etc/udev/rules.d/50-dock.rules
	ACTION=="change", BUS="usb", ATTRS{idVendor}=="17ef", ATTRS{idProduct}=="3082", NAME="dock", RUN="autorandr --batch --change"

Note that I used device `17ef:3082` but it could be any of

	Bus 006 Device 004: ID 17ef:3082 Lenovo
	Bus 006 Device 003: ID 17ef:307f Lenovo USB3.1 Hub
	Bus 006 Device 002: ID 17ef:307f Lenovo USB3.1 Hub
	Bus 006 Device 001: ID 1d6b:0003 Linux Foundation 3.0 root hub
	Bus 005 Device 007: ID 2109:8818 VIA Labs, Inc.
	Bus 005 Device 010: ID 2109:8818 VIA Labs, Inc.
	Bus 005 Device 009: ID 17ef:3083 Lenovo
	Bus 005 Device 006: ID 17ef:3081 Lenovo
	Bus 005 Device 003: ID 17ef:3080 Lenovo
	Bus 005 Device 002: ID 17ef:3080 Lenovo USB2.0 Hub
	Bus 005 Device 001: ID 1d6b:0002 Linux Foundation 2.0 root hub

Reload rules.

	udevadm control --reload-rules

> *TODO* xrandr seems to be triggered by something else. Auto config switching
> still works after disabling `udev` rule. I am truly puzzled.


## Tablet mode

See [this other post](/2019/12/09/detect-x1-yoga-tablet-mode-on-arch-linux).


## UI

### i3

	# resize large floating windows
	for_window [window_role="GtkFileChooserDialog"] resize set 1920 1440 # 4K
	for_window [window_role="GtkFileChooserDialog"] resize set 1440 960  # 2.5K

## Troubleshooting

### External screens and autodock

If using external screens via dock, `autorandr`, and `udev` rules,
use compatible resolution, e.g. `2560x1440` with `Xft.dpi: 144`.

Undocking does not properly roll back to the max resolution `3840x2160` (maybe
because `autorandr` is called from outside X session? bug?).

Then configure various resolutions with `autorandr` then create a file
`/etc/X11/xinit/xinitrc.d/10-autorandr.sh` with the following contents

    #!/bin/sh
    [ -x /usr/bin/autorandr ] && /usr/bin/autorandr --change

And make it executable

    chmod a+x /etc/X11/xinit/xinitrc.d/10-autorandr.sh

See [this gist](https://github.com/aureooms/dotfiles/wiki/Make-xrandr-config-permanent/f7ee1481951102e1d499e9d5c2b716568a893626).

## Mysteries

### Detect stylus is docked

?

## Sensors

	cat /sys/bus/iio/devices/iio:device*/name
	gyro_3d
	accel_3d

https://www.instructables.com/id/Accelerometer-Gyro-Tutorial

`accel_3d` measures orientation
`gyro_3d` measures orientation change

## Libinput events

	libinput debug-events
	-event2   DEVICE_ADDED     Power Button                      seat0 default group1  cap:k
	-event12  DEVICE_ADDED     Video Bus                         seat0 default group2  cap:k
	-event1   DEVICE_ADDED     Lid Switch                        seat0 default group3  cap:S
	-event0   DEVICE_ADDED     Sleep Button                      seat0 default group4  cap:k
	-event4   DEVICE_ADDED     Wacom Pen and multitouch sensor Finger seat0 default group5  cap:t  size 309x174mm ntouches 10 calib
	-event7   DEVICE_ADDED     Wacom Pen and multitouch sensor Pen seat0 default group5  cap:T  size 309x174mm calib
	-event10  DEVICE_ADDED     Integrated Camera: Integrated C   seat0 default group6  cap:k
	-event11  DEVICE_ADDED     Integrated Camera: Integrated I   seat0 default group6  cap:k
	-event5   DEVICE_ADDED     SYNA8004:00 06CB:CD8B Touchpad    seat0 default group7  cap:pg  size 97x53mm tap(dl off) left scroll-nat scroll-2fg-edge click-buttonareas-clickfinger dwt-on
	-event14  DEVICE_ADDED     HDA Intel PCH Mic                 seat0 default group8  cap:
	-event15  DEVICE_ADDED     HDA Intel PCH Headphone           seat0 default group8  cap:
	-event16  DEVICE_ADDED     HDA Intel PCH HDMI/DP,pcm=3       seat0 default group8  cap:
	-event17  DEVICE_ADDED     HDA Intel PCH HDMI/DP,pcm=7       seat0 default group8  cap:
	-event18  DEVICE_ADDED     HDA Intel PCH HDMI/DP,pcm=8       seat0 default group8  cap:
	-event19  DEVICE_ADDED     HDA Intel PCH HDMI/DP,pcm=9       seat0 default group8  cap:
	-event20  DEVICE_ADDED     HDA Intel PCH HDMI/DP,pcm=10      seat0 default group8  cap:
	-event3   DEVICE_ADDED     AT Translated Set 2 keyboard      seat0 default group9  cap:k
	-event6   DEVICE_ADDED     TPPS/2 ALPS TrackPoint            seat0 default group10 cap:p left scroll-nat scroll-button
	-event9   DEVICE_ADDED     ThinkPad Extra Buttons            seat0 default group11 cap:kS

	# move stylus close to screen
	-event7   TABLET_TOOL_PROXIMITY +40.30s		271.40*/124.25*	tilt: 0.00*/0.00*	pressure: 0.00*	pen (0x????????, id 0x??) proximity-in 	axes:pt	btn:SS2
	 event7   TABLET_TOOL_PROXIMITY +40.76s		276.00/119.19	tilt: 0.00/0.00 pressure: 0.00	pen (0x????????, id 0x??) proximity-out

	# toggle table-mode by rotating screen beyong 180 deg
	-event9   SWITCH_TOGGLE    +59.14s	switch tablet-mode state 1
	 event9   SWITCH_TOGGLE    +65.44s	switch tablet-mode state 0

## See also

[Arch wiki link](https://wiki.archlinux.org/index.php/Lenovo_ThinkPad_X1_Yoga_(Gen_4)).

Also very similar to: https://wiki.archlinux.org/index.php/Lenovo_ThinkPad_X1_Carbon_(Gen_7)
