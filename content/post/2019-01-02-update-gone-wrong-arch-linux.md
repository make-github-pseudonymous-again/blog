---
title: Update Gone Wrong Arch Linux
date: 2019-01-02T23:05:01+01:00
tags:
  - Arch
---

This will likely mess up your system even more...

<!--more-->

### Mount the root partition

#### With an encrypted drive

	cryptsetup luksOpen /dev/sdxi arch
	mount /dev/mapper/arch /mnt

If it says

	mount: unknown filesystem type 'LVM2_member'

Try

	vgchange -ay
	lvscan
	...
	mount /dev/volume/XXX /mnt


#### With an unencrypted drive

	mount /dev/sdxi /mnt

### Mount the boot partition and others

	cd /mnt
	mount -t proc proc proc/
	mount -t sysfs sys sys/
	mount -o bind /dev dev/
	mount /dev/sdyj boot/

### Update the mounted system

	chroot . /bin/bash
	pacman -Syu
	pacman -S udev
	pacman -S mkinitcpio
	mkinitcpio -p linux

### Finally

Unmount and reboot

	exit
	cd
	sync
	umount -R /mnt
	reboot

### Troubleshooting

Sometimes you will see the following error message

	error: ... (could not lock database)

The answer is

	rm /var/lib/pacman/db.lck

You might also see the following error message

	error: failed retrieving ...

The solution is

	echo 'nameserver 8.8.8.8' > /etc/resolv.conf
