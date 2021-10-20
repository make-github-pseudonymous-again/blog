---
title: Encrypted Install With Arch Linux on UEFI
date: 2019-01-03T00:27:32+01:00
tags:
  - Security
  - Encryption
---

So easy!

<!--more-->

Follow the excellent
[video](https://ipfs.xn--mxac.cc/ipfs/QmTmzyHjzKdRD31eY4ueVYwyaxBaDCMSpE5LnU348vqXT1).

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

Partition LVM volume

	pvcreate /dev/mapper/main
	vgcreate main /dev/mapper/main
	lvcreate -L2G main -n swap
	lvcreate -l 100%FREE main -n root


Format root partition

	mkfs.ext4 /dev/mapper/main-root

Format swap partition

	mkswap /dev/mapper/main-swap

Mount partitions

	mount /dev/mapper/main-root /mnt
	mkdir /mnt/boot
	mount /dev/sda1 /mnt/boot
	swapon /dev/mapper/main-swap

Bootstrap installation (tweak `/etc/pacman.d/mirrorlist` if too slow)

	pacstrap /mnt mkinitcpio linux linux-firmware lvm2 base base-devel dhcpcd netctl iw dialog wpa_supplicant wireless_tools vi gvim git firefox
	pacstrap /mnt mkinitcpio linux linux-firmware lvm2 base base-devel dhcpcd vi gvim git firefox # without WiFi

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
	HOOKS=(base udev autodetect modconf block keyboard encrypt lvm2 filesystems fsck)

Optionally throw in some `consolefont` and `keymap` hooks if you plan to
customize them.

	# /etc/mkinitcpio.conf
	HOOKS=(base udev autodetect modconf block consolefont keymap keyboard encrypt lvm2 filesystems fsck)

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
	options cryptdevice=UUID=<UUID>:main root=/dev/mapper/main-root rw

Replace `<UUID>` with the UUID found in `:read !blkid /dev/sda2`.

Unmount and reboot

	exit
	cd
	sync
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
