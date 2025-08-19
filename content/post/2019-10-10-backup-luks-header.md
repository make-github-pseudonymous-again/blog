---
title: "Backup LUKS header"
date: 2019-10-10T00:00:00+00:00
lastmod: 2025-08-19T00:00:00+00:00
tags:
  - Security
  - Backup
  - Encryption
  - LUKS
  - Redundancy
---

LUKS partitions cannot be recovered once the header is lost.

<!--more-->

Create a directory only accessible by root with a `ramfs` (to minimize the risk
of leaking the unencrypted header through, e.g., storage persistence):

	mkdir /root/<tmp>
	mount ramfs /root/<tmp> -t ramfs

Create a backup image of the header:

	cryptsetup luksHeaderBackup /dev/<device> --header-backup-file /root/<tmp>/<file>.img

Check that the backup image of the header works by using it as a "detached"
header:

	cryptsetup luksOpen --test-passphrase /dev/<device> --header /root/<tmp>/<file>.img

Encrypt the image with `gpg`

	gpg2 --recipient <Recipient ID> --encrypt /root/<tmp>/<file>.img

Move the encrypted file (`/root/<tmp>/<file>.img.gpg`) to persistent storage.

To check that the file did not get corrupted by encryption or by copying the
file, you can compare their checksums. For instance, for the original backup
image:

	sha256sum /root/<tmp>/<file>.img

And for the encrypted copy, potentially on a different device:

	gpg --decrypt <file>.img.gpg | sha256sum


When you are done, unmount the temporary `ramfs` directory:

	umount /root/<tmp>

See also https://wiki.archlinux.org/index.php/Dm-crypt/Device_encryption#Backup_and_restore
