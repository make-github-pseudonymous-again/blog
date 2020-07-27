---
title: "Automatically Mount LUKS Encrypted Device With Systemd"
date: 2018-05-24T17:27:54+02:00
tags:
  - Automation
  - LUKS
  - Security
  - Encryption
  - udev
  - systemd
---

Following the [good advice of
laclaro](https://laclaro.wordpress.com/2017/11/02/mount-encrypted-disk-with-systemd).

<!--more-->

We assume your device is already encrypted with LUKS. All commands are run as
root.

> **WARNING!** Here we will name our device `storage`. Should you use another
> name, make sure it does not conflict with existing names on the file system.
> For example naming your device `usb` would conflict with the existing
> `/dev/usb`, resulting in mysterious errors.

Create a new key for device:

	$ mkdir /root/key
	$ dd bs=512 count=4 if=/dev/urandom of=/root/key/storage
	$ cryptsetup luksAddKey /dev/sdx1 /root/key/storage

Grab device serial number

	$ udevadm info -n /dev/sdb1 | grep SERIAL

We will call our device `storage`. It will be mounted at `/media/storage`.

	$ cat /etc/udev/rules.d/storage.rules
	ACTION=="add", KERNEL=="sd[a-z][0-9]", ENV{ID_SERIAL_SHORT}=="putserialnumberhere", SYMLINK+="storage", TAG+="systemd", ENV{SYSTEMD_WANTS}+="media-storage.mount"

	$ cat /etc/systemd/system/media-storage.mount
	[Unit]
	Conflicts=umount.target
	Before=umount.target
	BindsTo=storage-decrypt.service dev-storage.device
	After=storage-decrypt.service dev-mapper-storage.device
	# you may specify some unit file that depends on media-storage.mount
	# Wants=storage-postmount.service
	[Mount]
	What=/dev/mapper/storage
	Where=/media/storage
	Type=ext4
	Options=defaults,rw,noexec,x-systemd.automount,relatime

	$ cat /etc/systemd/system/storage-decrypt.service
	[Unit]
	Description=storage decrypt
	BindsTo=media-storage.mount dev-storage.device
	Requires=dev-storage.device
	After=dev-storage.device
	DefaultDependencies=no

	[Service]
	Type=oneshot
	TimeoutStartSec=0
	RemainAfterExit=yes
	KillMode=none
	ExecStart=/sbin/cryptsetup luksOpen -d /root/key/storage /dev/storage storage
	ExecStop=/sbin/cryptsetup luksClose storage

	[Install]
	RequiredBy=media-storage.mount

Unplug your device. Reload the config:

	$ udevadm control --reload-rules
	$ systemctl daemon-reload

Replug your device.

> **NB**: If you want a user other than root to have access to the drive,
> simply run `chown -R username:group /media/storage` while the device is
> mounted. For guest filesystems different from `ext4`, there might be
> another (better) solution involving the `-o` flag of `mount`.
> See https://superuser.com/q/320415/168948 for further information.
