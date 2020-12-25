---
title: Almost-Live Disk Swap
date: 2020-12-25T01:32:19+01:00
draft: true
---

Existing disk: `/dev/sda`.
New disk: `/dev/sdb`.

Partition and encrypt new disk (for instance following one of the
install guides).

Format main volume with `btrfs` for instance (here I use a SSD):

    mkfs.btrfs -d single -m single /dev/mapper/main

Mount partitions:

    mount /dev/mapper/main /mnt
    mkdir /mnt/boot
    mount /dev/sdb1 /mnt/boot

Block device mapping should look like:

    [root@x ~]# lsblk
    NAME     MAJ:MIN RM   SIZE RO TYPE  MOUNTPOINT
    sda        8:0    0 698.6G  0 disk  
    ├─sda1     8:1    0   512M  0 part  /boot
    └─sda2     8:2    0 698.1G  0 part  
      └─root 254:0    0 698.1G  0 crypt /
    sdb        8:16   0 476.9G  0 disk  
    ├─sdb1     8:17   0   512M  0 part  /mnt/boot
    └─sdb2     8:18   0 476.4G  0 part  
      └─main 254:1    0 476.4G  0 crypt /mnt

Do a full backup of `/` to `/mnt` (by ignoring generated files and avoiding self-reference):

    rsync -aAXH --delete --info=progress2 --exclude={"/dev/*","/proc/*","/sys/*","/tmp/*","/run/*","/mnt/*","/media/*","/lost+found","/var/lib/dhcpcd/*","/home/*/.gvfs"} / /mnt

Generate `/etc/fstab`

    genfstab -U /mnt >> /mnt/etc/fstab

Comment out old entries in `/mnt/etc/fstab` then chroot into new FS:

    arch-chroot /mnt

Initramfs

    mkinitcpio -P

Reinstall the bootloader

    bootctl --path=/boot install

Edit boot entries disk UUIDs.

Remove old machine id

    rm /etc/machine-id

Exit, reboot, configure firmware to boot from new disk.
