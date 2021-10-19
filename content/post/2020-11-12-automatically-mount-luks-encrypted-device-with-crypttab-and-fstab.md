---
title: "Automatically Mount LUKS Encrypted Device with Crypttab and Fstab"
date: 2020-11-12T20:00:00+01:00
tags:
  - Automation
  - LUKS
  - Security
  - Encryption
  - fstab
  - crypttab
---

Put that second drive to use!

<!--more-->

> **WARNING!** Here we will name our device `storage`. Should you use another
> name, make sure it does not conflict with existing names on the file system.
> For example naming your device `usb` would conflict with the existing
> `/dev/usb`, resulting in mysterious errors.

Create GPT partition with one part (we use GPT because MBR is obsolete)

	parted /dev/sdx mklabel gpt
	parted --align optimal /dev/sdx mkpart primary ext4 0% 100%

Create symmetric encryption key

	mkdir -p /root/key
	dd bs=512 count=4 if=/dev/urandom of=/root/key/storage iflag=fullblock
	chmod 0400 /root/key/storage

Setup LUKS on the part

	cryptsetup luksFormat /dev/sdx1 /root/key/storage

Open, format as `ext4`, then close

	cryptsetup --key-file /root/key/storage luksOpen /dev/sdx1 storage
	mkfs.ext4 /dev/mapper/storage
	cryptsetup close storage

Configure crypttab to manage part encryption

	blkid /dev/sdx1
	/dev/sdx1: UUID="<UUID>" ...

	cat /etc/crypttab
	...
	storage        UUID=<UUID>    /root/key/storage

Configure fstab to manage part mounting.

	mkdir -p /media/storage
	/dev/mapper/storage        /media/storage   ext4        defaults        0 2

Note that we do not use `nofail` since we assume the system will rely on
`/media/storage` to be mounted in order to function properly.
