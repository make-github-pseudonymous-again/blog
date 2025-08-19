---
date: 2024-09-21T00:00:00Z
title: Configure firewall on Arch Linux with `ufw`
tags:
  - Installation
  - Arch
  - ufw
draft: true
---

Arch Linux allows all network traffic by default. This is an unreasonable
default for personal computers, and most servers. Let's fix that.

<!--more-->

(Follows https://wiki.archlinux.org/title/Uncomplicated_Firewall)


Install the package `ufw`:

    pacman -S ufw


Check that `iptables.service` is disabled:

    $ systemctl status iptables
    ○ iptables.service - IPv4 Packet Filtering Framework
         Loaded: loaded (/usr/lib/systemd/system/iptables.service; disabled; preset: disabled)
         Active: inactive (dead)


Enable `ufw.service`:

    systemctl enable --now ufw


Deny all traffic by default:

    ufw default deny


Enable `ufw` rules:

    ufw enable


TODO: Allow certain services

TODO: Make it work with `docker` (ufw-docker)
