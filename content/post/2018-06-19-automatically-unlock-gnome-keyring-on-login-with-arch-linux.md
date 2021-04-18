---
title: "Automatically Unlock Gnome Keyring on Login With Arch Linux"
date: 2018-06-19T12:44:02+02:00
tags:
  - Automation
  - Security
---

So that only your session password is needed.

<!--more-->

Install `gnome-keyring`, `libsecret`, and `seahorse`.

Start `seahorse` and create a keyring named `login` with the same password as
your login password and set it as default.
If such a keyring already exists and you remember its password, make sure its
password is the same as your login password.
If such a keyring already exists and you do not remember its password, delete
it and create a new one.

Follow the instructions
[here](https://wiki.archlinux.org/index.php/GNOME/Keyring#Console_login):

In `/etc/pam.d/login`, add `auth optional pam_gnome_keyring.so` at the end of
the auth section and `session optional pam_gnome_keyring.so auto_start` at the
end of the session section.

	#%PAM-1.0

	auth       required     pam_securetty.so
	auth       requisite    pam_nologin.so
	auth       include      system-local-login
	auth       optional     pam_gnome_keyring.so
	account    include      system-local-login
	session    include      system-local-login
	session    optional     pam_gnome_keyring.so auto_start

Reboot.

## TODO

Add instructions on how to add gnupg keys to the keyring.

Add instructions on how to add ssh keys to the keyring.
