---
date: 2020-12-26T00:00:00Z
title: Configure SSD trim with LUKS
tags:
  - SSD
  - LUKS
draft: true
---

Check which drives can be trimmed with `lsblk --discard`.
If `>= 1` then enable and start `fstrim.timer`

    systemctl enable --now fstrim.timer

Configure LUKS to let TRIM pass through:

  - `systemd-boot`/`GRUB`: Add `:allow-discards` to cryptdevice options.
  - `crypttab`: Add `discard` option.
