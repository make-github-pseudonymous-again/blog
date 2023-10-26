---
date: 2023-10-01T00:00:00Z
title: Automated snapshots with Btrfs
tags:
  - Arch Linux
  - Btrfs
  - Backup
  - Snapshots
  - snapper
  - snap-pac
  - pacman
---

Install `snapper`

```sh
pacman -S snapper
```

Make sure to have followed
[`snapper`'s recommendations regarding Btrfs subvolumes layout](https://wiki.archlinux.org/title/Snapper#Suggested_filesystem_layout).
Note that `snapper` creates a subvolume for snapshots at `/.snapshots` but with
an unnecessary parent dependency on `@`.

To allow `snapper` to go through the configuration step, make sure you have
unmounted any subvolume (or other) mounted at `/.snaphosts` and deleted any
corresponding directory.

```sh
umount /.snapshots
rm -r /.snapshots
```

Create configuration for the root subvolume

```sh
snapper -c root create-config /
```

Then delete the subvolume automatically created by `snapper`

```sh
btrfs subvolume delete /.snapshots
```

And replace it with an independent `@snapshots` subvolume (if you had already
created it, `mkdir /.snapshots && mount -a` should suffice).

Existing configurations can be listed with

```sh
snapper list-configs
```

You can edit configurations under `/etc/snapper/configs/`.

To enable [automatic timeline snapshots](https://wiki.archlinux.org/title/Snapper#Automatic_timeline_snapshots) simply install `cronie` and enable the corresponding systemd system service:

```sh
pacman -S cronie
systemctl enable --now cronie
```

To enable automatic pacman transactions snapshots for `/`, install `snap-pac`:

```sh
pacman -S snap-pac
```

You can configure `snap-pac` at `/etc/snap-pac.ini`.

To enable automatic pacman transactions snapshots for `/boot`, create the
following pacman post-transaction hook:

```
# File: /etc/pacman.d/hooks/95-bootbackup.hook
[Trigger]
Operation = Upgrade
Operation = Install
Operation = Remove
Type = Path
Target = usr/lib/modules/*/vmlinuz

[Action]
Depends = rsync
Description = Backing up /boot...
When = PostTransaction
Exec = /usr/bin/rsync -a --delete /boot /.boot.bak
```

Note that since the backup is stored on the root subvolume, it should be
possible to access previous backups by restoring previous snapshots of the root
subvolume.


To enable automatic snapshots on boot, enable `snapper-boot.timer`:

```sh
systemctl enable --now snapper-boot.timer
```

Existing snapshots can be listed with

```sh
snapper list
```

See also:
  - https://wiki.archlinux.org/title/Btrfs#Snapshots
  - https://wiki.archlinux.org/title/snapper

