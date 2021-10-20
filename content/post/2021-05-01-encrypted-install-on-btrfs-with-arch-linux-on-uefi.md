---
title: Encrypted Install on Btrfs with Arch Linux on UEFI
date: 2021-05-01T00:00:00+01:00
tags:
  - Security
  - Encryption
---

So easy!

<!--more-->

  - Bootloader: `bootctl`
  - Encryption: `LUKS`
  - Filesystem: `Btrfs`

Check you are in EFI mode

	ls /sys/firmware/efi
	...

Update the system clock

	timedatectl set-ntp true

List disks

	lsblk

Partition the storage device

	gdisk /dev/sda
	o
	y
	n
	<enter>
	<enter>
	+512MiB
	ef00
	n
	<enter>
	<enter>
	<enter>
	8e00
	w
	y

Format boot partition

	mkfs.fat -F32 /dev/sda1

Encrypt main partition

	cryptsetup luksFormat /dev/sda2
	YES
	<passphrase>
	<passphrase>

Open main partition

	cryptsetup luksOpen /dev/sda2 main
	<passphrase>

Format Btrfs volume

	mkfs.btrfs -d single -m single /dev/mapper/main

Mount Btrfs volume

	mount /dev/mapper/main /mnt

Create Btrfs subvolumes

	cd /mnt
	btrfs subvolume create @
	btrfs subvolume create @home
	btrfs subvolume create @snapshots
	btrfs subvolume create @swap

Mount Btrfs main volume, boot partition, and Btrfs subolumes

	cd
	umount /mnt
	mount -o noatime,subvol=@ /dev/mapper/main /mnt
	mkdir /mnt/boot
	mount /dev/sda1 /mnt/boot
	mkdir /mnt/home
	mount -o noatime,subvol=@home /dev/mapper/main /mnt/home
	mkdir /mnt/.snapshots
	mount -o noatime,subvol=@snapshots /dev/mapper/main /mnt/.snapshots
	mkdir /mnt/swap
	mount -o noatime,subvol=@swap /dev/mapper/main /mnt/swap

Create swap file

	touch /mnt/swap/swapfile
	truncate -s 0 /mnt/swap/swapfile
	chmod 600 /mnt/swap/swapfile
	chattr +C /mnt/swap/swapfile
	btrfs property set /mnt/swap/swapfile compression none
	dd if=/dev/zero of=/mnt/swap/swapfile bs=1M count=4096 status=progress
	mkswap /mnt/swap/swapfile
	swapon /mnt/swap/swapfile

Bootstrap installation (tweak `/etc/pacman.d/mirrorlist` if too slow)

	pacstrap /mnt mkinitcpio linux linux-firmware btrfs-progs base base-devel dhcpcd vi gvim git firefox iwd
	pacstrap /mnt mkinitcpio linux linux-firmware btrfs-progs base base-devel dhcpcd vi gvim git firefox # without WiFi

Generate /etc/fstab

	genfstab -p /mnt >> /mnt/etc/fstab

Chroot

	arch-chroot /mnt

Configure time

	rm /etc/localtime
	ln -s /usr/share/zoneinfo/Europe/Brussels /etc/localtime
	hwclock --systohc --utc

Create root password

	passwd
	<password>
	<password>

Uncomment `UTF8` and `ISO-8859-1` `en_US` lines in `/etc/locale.gen`.

	# /etc/locale.gen
	en_US.UTF-8 UTF-8
	en_US ISO-8859-1

Then

	locale-gen
	locale > /etc/locale.conf

Configure the hostname

	echo "hostname" > /etc/hostname

Give keyboard access before mounting to type encryption password

	# /etc/mkinitcpio.conf
	HOOKS=(base udev autodetect modconf block keyboard encrypt filesystems fsck)

Optionally throw in some `consolefont` and `keymap` hooks if you plan to
customize them.

	# /etc/mkinitcpio.conf
	HOOKS=(base udev autodetect modconf block consolefont keymap keyboard encrypt filesystems fsck)

Regenerate initramfs

	mkinitcpio -p linux

Install the bootloader

	bootctl --path=/boot install

Create boot loader

	# /boot/loader/loader.conf
	default arch.conf
	timeout 3
	editor 0
	console-mode auto # see https://github.com/systemd/systemd/pull/8086/commits/68d4b8ac9b9673637fa198b735f6e64b78b35d3b
	# console-mode max

Create boot loader entry

	# /boot/loader/entries/arch.conf
	title Arch Linux
	linux /vmlinuz-linux
	initrd /initramfs-linux.img
	options cryptdevice=UUID=<UUID>:main:allow-discards root=/dev/mapper/main rootflags=subvol=@ rw

**NOTE**: `:allow-discards` should not be used if not SSD storage.

Replace `<UUID>` with the UUID found in `:read !blkid /dev/sda2`.

Unmount and reboot

	exit
	cd
	sync
	swapoff /mnt/swap/swapfile
	umount -R /mnt
	reboot

Create an admin user (uncomment the appropriate `%wheel` line via `visudo`)

	useradd -m -G wheel theadminusername
	passwd theadminusername
	<password>
	<password>

Note that the login shell can be changed with

	chsh -s <shell> <username>

The list of available shells is available at `less /etc/shells`.
