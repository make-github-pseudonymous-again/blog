---
date: 2020-12-25T00:00:00Z
title: Configure microcode with GRUB
tags:
  - Installation
  - Arch
  - GRUB
---

All users with an AMD or Intel CPU should install the microcode updates to
ensure system stability.

<!--more-->

(Follows https://wiki.archlinux.org/index.php/Microcode)

Install Intel or AMD package:

    pacman -S intel-ucode

or

    pacman -S amd-ucode

Regenerate GRUB config

    grub-mkconfig -o /boot/grub/grub.cfg
