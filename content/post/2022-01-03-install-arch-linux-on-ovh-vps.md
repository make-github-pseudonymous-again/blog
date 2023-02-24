---
date: 2022-01-03T00:00:00Z
title: Install Arch Linux on OVH VPS
tags:
  - Arch Linux
  - OVH
  - VPS
draft: true
---

Following
https://www.dimoulis.net/posts/install-arch-linux-on-ovh-vps/

	apt install qemu-utils

	mkdir /tmp/mnt
	mount -t tmpfs tmpfs /tmp/mnt
	cd /tmp/mnt

	curl 'https://mirror.pkgbuild.com/images/latest/' | grep 'a href' | sed 's/.*href="\([^"]\+\)".*/\1/' | grep cloudimg | xargs -L1 -I{} wget 'https://mirror.pkgbuild.com/images/latest/{}'

	diff <(sha256sum Arch-Linux-*.qcow2) Arch-Linux*.qcow2.SHA256

	qemu-img convert -f qcow2 -O raw Arch-Linux-x86_64-cloudimg-*.qcow2 /dev/sdb

	sfdisk -l /dev/sdb

	mount -t btrfs /dev/sdb2 /mnt

	chroot /mnt

	echo "arch ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/arch

	useradd -m -s /bin/bash -G wheel arch

	passwd arch

REBOOT through web interface (NOT in rescue mode)

	sudo pacman -Syu
	sudo pacman -S cloud-guest-utils qemu-guest-agent pacman-contrib vim --needed
	sudo pacdiff
	sudo systemctl enable qemu-guest-agent.service

EDIT `/etc/default/grub`

	GRUB_CMDLINE_LINUX_DEFAULT="rootflags=compress-force=zstd random.trust_cpu=on"
	GRUB_CMDLINE_LINUX="net.ifnames=0 console=ttyS0"

	sudo grub-mkconfig -o /boot/grub/grub.cfg

	sudo reboot

	sudo btrfs filesystem defragment -r /
