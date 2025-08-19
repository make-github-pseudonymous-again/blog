---
date: 2024-03-10T00:00:00Z
title: Configure microcode with mkinitcpio
tags:
  - Installation
  - Arch
  - mkinitcpio
draft: true
---

All users with an AMD or Intel CPU should install the microcode updates to
ensure system stability.

<!--more-->

(Follows https://wiki.archlinux.org/index.php/Microcode)

Install Intel or AMD package (depending on your CPU, check `lscpu`):

    pacman -S intel-ucode

or

    pacman -S amd-ucode


Add `microcode` hook to `mkinitcpio.conf`:

    hooks=(... microcode ...)
