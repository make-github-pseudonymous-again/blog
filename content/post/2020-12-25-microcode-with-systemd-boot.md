---
date: 2020-12-25T00:00:00Z
title: Configure microcode with systemd-boot
tags:
  - Installation
  - Arch
  - systemd-boot
---

All users with an AMD or Intel CPU should install the microcode updates to
ensure system stability.

<!--more-->

(Follows https://wiki.archlinux.org/index.php/Microcode)

Install Intel or AMD package (depending on your CPU, check `lscpu`):

    pacman -S intel-ucode

or

    pacman -S amd-ucode


Add initrd line to boot loader config:

    title Arch Linux
    linux /vmlinuz-linux
    initrd /intel-ucode.img
    initrd /initramfs-linux.img
    options ...

or 

    title Arch Linux
    linux /vmlinuz-linux
    initrd /amd-ucode.img
    initrd /initramfs-linux.img
    options ...
