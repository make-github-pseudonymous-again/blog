---
title: "Connect Phone to Arch Linux"
date: 2019-12-03T13:02:29+01:00
tags:
  - Phone
---

To transfer files.

<!--more-->

Install `gvfs`

	pacman -S gvfs

For Android devices (PTP)

	pacman -S gvfs-gphoto2

For Android devices (MTP)

	pacman -S gvfs-mtp

For Apple devices

	pacman -S gvfs-afc

## See also

All available packages

	extra/gvfs 1.42.2-1 (gnome)
		Virtual filesystem implementation for GIO
	extra/gvfs-afc 1.42.2-1 (gnome)
		Virtual filesystem implementation for GIO (AFC backend; Apple mobile devices)
	extra/gvfs-goa 1.42.2-1 (gnome)
		Virtual filesystem implementation for GIO (Gnome Online Accounts backend; cloud storage)
	extra/gvfs-google 1.42.2-1 (gnome)
		Virtual filesystem implementation for GIO (Google Drive backend)
	extra/gvfs-gphoto2 1.42.2-1 (gnome)
		Virtual filesystem implementation for GIO (gphoto2 backend; PTP camera, MTP media player)
	extra/gvfs-mtp 1.42.2-1 (gnome)
		Virtual filesystem implementation for GIO (MTP backend; Android, media player)
	extra/gvfs-nfs 1.42.2-1 (gnome)
		Virtual filesystem implementation for GIO (NFS backend)
	extra/gvfs-smb 1.42.2-1 (gnome)
		Virtual filesystem implementation for GIO (SMB/CIFS backend; Windows client)
