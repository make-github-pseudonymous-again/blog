---
date: 2025-01-19T00:00:00Z
title: Keep Pacman mirrors up-to-date with Reflector
tags:
  - Update
  - Arch
  - pacman
  - Reflector
---

To reduce Arch Linux update time.

<!--more-->

Install Reflector:

```sh
pacman -S reflector
```

Configure Reflector at `/etc/xdg/reflector/reflector.conf`:

```sh
# Reflector configuration file for the systemd service.
#
# Empty lines and lines beginning with "#" are ignored.  All other lines should
# contain valid reflector command-line arguments. The lines are parsed with
# Python's shlex modules so standard shell syntax should work. All arguments are
# collected into a single argument list.
#
# See "reflector --help" for details.

# Make it verbose
--verbose

# Set the output path where the mirrorlist will be saved (--save).
--save /etc/pacman.d/mirrorlist

# Use only one thread (to get accurate --sort rate results)
--threads 1

# Only return mirrors that support HTTPS
--protocol https

# Sort the mirrors by download speed.
--sort rate

# Select the country (--country).
# Consult the list of available countries with "reflector --list-countries" and
# select the countries nearest to you or the ones that you trust. For example:
--country "United Kingdom"

# Only return mirrors that have synchronized in the last n hours.
--age 30

# Return at most n mirrors
--number 20
```


Add `NoExtract = /etc/pacman.d/mirrorlist` to `/etc/pacman.conf`.


Finally, enable the corresponding `systemd` timer:

```sh
systemctl enable --now reflector.timer
```
