---
date: 2022-01-03T00:00:00Z
title: Install Arch Linux on OVH VPS
tags:
  - Arch
  - OVH
  - VPS
---

Following
https://www.dimoulis.net/posts/install-arch-linux-on-ovh-vps/


Install any available distribution such as e.g. Debian.

Log in the manager and reboot in rescue mode. The rescue system is Debian based
and includes backports and ZFS packages if you ever need them.


	apt-get update
	apt install qemu-utils

	mkdir /tmp/mnt
	mount -t tmpfs tmpfs /tmp/mnt
	cd /tmp/mnt

	curl 'https://mirror.pkgbuild.com/images/latest/' | grep 'a href' | sed 's/.*href="\([^"]\+\)".*/\1/' | grep cloudimg | xargs -L1 -I{} wget 'https://mirror.pkgbuild.com/images/latest/{}'

	diff <(sha256sum Arch-Linux-*-cloudimg-*.qcow2) Arch-Linux-*-cloudimg-*.qcow2.SHA256

	qemu-img convert -f qcow2 -O raw Arch-Linux-x86_64-cloudimg-*.qcow2 /dev/sdb

	sfdisk -l /dev/sdb

	mount -t btrfs /dev/sdb3 /mnt

	chroot /mnt

	echo "arch ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/arch

	useradd -m -s /bin/bash -G wheel arch

	passwd arch

REBOOT through web interface (NOT in rescue mode)

	sudo pacman -Syu
	sudo pacman -S cloud-guest-utils qemu-guest-agent pacman-contrib vim --needed
	sudo pacdiff
	systemctl status qemu-guest-agent

EDIT `/etc/default/grub`

	GRUB_CMDLINE_LINUX_DEFAULT="rootflags=compress-force=zstd console=tty0 console=ttyS0,115200 random.trust_cpu=on"
	GRUB_CMDLINE_LINUX="net.ifnames=0"

	sudo grub-mkconfig -o /boot/grub/grub.cfg

	sudo reboot

	sudo btrfs filesystem defragment -r /
