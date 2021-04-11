---
date: 2021-04-11T00:00:00Z
title: Encrypt user home with eCryptfs
tags:
  - Privacy
  - Security
  - Automation
---

We encrypt a user home directory with eCryptfs. The consequence is that the
contents of this directory are only accessible if at least one of the following is true:
  - You know the user's password.
  - The user is logged in\* AND you have read permission to the user's directory
    (if you are root for instance).

> \* or has processes surviving logout (for instance lingering services).

This may increase privacy, depending on how the system is used.

If the user home is not encrypted, it would suffice to be root (without the
user necessary being logged in). Note that being root on another system and
mounting the partition hosting the user's home suffices.

<!--more-->

## First, configure auto-mounting via PAM (once per system)

(Follows https://wiki.archlinux.org/index.php/ECryptfs#Auto-mounting)

Add `pam_succeed_if.so` and `pam_ecryptfs.so` lines to `/etc/pam.d/system-auth`
so that it looks as follows:

```
#%PAM-1.0

auth       required                    pam_faillock.so      preauth
# Optionally use requisite above if you do not want to prompt for the password
# on locked accounts.
auth       [success=2 default=ignore]  pam_unix.so          try_first_pass nullok
-auth      [success=1 default=ignore]  pam_systemd_home.so
auth       [default=die]               pam_faillock.so      authfail
auth       [success=1 default=ignore]  pam_succeed_if.so    service = systemd-user quiet
auth       required                    pam_ecryptfs.so      unwrap
auth       optional                    pam_permit.so
auth       required                    pam_env.so
auth       required                    pam_faillock.so      authsucc
# If you drop the above call to pam_faillock.so the lock will be done also
# on non-consecutive authentication failures.

-account   [success=1 default=ignore]  pam_systemd_home.so
account    required                    pam_unix.so
account    optional                    pam_permit.so
account    required                    pam_time.so

password   optional                    pam_ecryptfs.so
-password  [success=1 default=ignore]  pam_systemd_home.so
password   required                    pam_unix.so          try_first_pass nullok shadow
password   optional                    pam_permit.so

session    required                    pam_limits.so
session    required                    pam_unix.so
session    [success=1 default=ignore]  pam_succeed_if.so    service = systemd-user quiet
session    optional                    pam_ecryptfs.so      unwrap
session    optional                    pam_permit.so
```

> According to the wiki, `pam_succeed_if.so` lines are a workaround. Maybe
> these will be useless in the future.

On the wiki, there are additional instructions on how to make auto-mounting
work with `su -l` login.

## Second, encrypt user home (once per user)

(Follows https://wiki.archlinux.org/index.php/ECryptfs#Encrypting_a_home_directory)

> Make sure the user is logged out and owns no processes. The
> best way to achieve this is to log the user out, log into a console as the
> root user, and check that ps -U username returns no output. You also need to
> ensure that you have rsync, lsof, and which installed.

> The package providing `ecryptfs-migrate-home` can be found via `pacman -F
> ecryptfs-migrate-home`.

```sh
modprobe ecryptfs
ecryptfs-migrate-home -u username
```

The user `username` MUST login before the next reboot for the migration to be
complete. An unencrypted backup of `/home/username` can be found at
`/home/username.random_characters` and SHOULD be deleted once the migration is
confirmed to be complete.
