---
title: Remote LUKS unlocking with TinySSH
date: 2021-10-20T00:00:00+01:00
tags:
  - Automation
  - Security
  - Encryption
  - LUKS
  - SSH
---

Goodbye keyboards and monitors!

<!--more-->

This guide assumes you already have a system with LUKS root encryption. See for
instance:
  - [UEFI/LUKS/Btrfs install]({{<ref "2021-05-01-encrypted-install-on-btrfs-with-arch-linux-on-uefi">}})
  - [UEFI/LUKS/LVM/ext4 install]({{<ref "2019-01-03-encrypted-install-with-arch-linux-on-uefi">}})
  - [BIOS/LUKS/LVM/ext4 install]({{<ref "2019-10-12-encrypted-install-with-arch-linux-on-bios">}})

## Dependencies

    pacman -S mkinitcpio-{netconf,tinyssh,utils}

## /etc/tinyssh/root\_key

Put a `ed25519` public key there
(for instance, generated with `ssh-keygen -t ed25519`).
Syntax is identical to `~/.ssh/authorized_keys`.

## /etc/mkinitcpio.conf

Replace `encrypt` hook as follows:

```diff
-HOOKS=(... encrypt ...)
+HOOKS=(... netconf tinyssh encryptssh ...)
```

Regenerate `initramfs`

    mkinitcpio -P

**NB1**:
You may notice a `tinyssh-convert` usage message when running `mkinicpio -P`.
This is because
[the current release of `mkinitcpio-tinyssh` is broken](https://bugs.archlinux.org/task/74522?project=1&opened=37246).
To fix:

    rm -r /etc/tinyssh/sshkeydir
    tinyssh-convert < /etc/ssh/ssh_host_ed25519_key /etc/tinyssh/sshkeydir/
    mkinitcpio -P

**NB2**: No need to add ethernet module `e1000e`. Other modules might behave
differently. This depends on correct behavior of the `autodetect` hook.

    MODULES=()
    ...
    HOOKS=(base udev autodetect ...)


## Boot loader entry

Add the following parameters to your `options` line

    ip=<static-address>::<gateway>:<subnet-mask>::eth0:none

You can find the kernel interface name (`eth0`) by scanning through `dmesg`.

**NB**: DHCP (`ip=dhcp` or `ip=:::::eth0:dhcp` with `netconf_timeout=60`)
does not seem to work.
