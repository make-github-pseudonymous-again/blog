---
title: "Suspend Resume Hooks"
date: 2020-06-24T10:15:37+02:00
tags:
  - Automation
  - Screen Lock
  - Suspend
  - systemd
---

For instance, to lock the screen on suspend. Can also be used to toggle WiFi,
Bluetooth, etc.

<!--more-->

Define the two following units:

A unit for when the system goes to sleep.

    # /etc/systemd/system/suspend@.service
    [Unit]
    Description=Suspend actions for user %I
    Before=sleep.target

    [Service]
    User=%i
    Type=forking
    Environment=DISPLAY=:0
    ExecStart=/usr/bin/env sh /home/%i/.bin/on-suspend
    ExecStartPost=/usr/bin/sleep 1

    [Install]
    WantedBy=sleep.target

And a unit for when the system resumes from sleep.

    # /etc/systemd/system/resume@.service
    [Unit]
    Description=Resume actions for user %I
    After=suspend.target

    [Service]
    User=%i
    Type=simple
    ExecStart=/usr/bin/env sh /home/%i/.bin/on-resume

    [Install]
    WantedBy=suspend.target


Enable `suspend@username` and `resume@username`.

Edit the scripts `on-suspend` and `on-resume`.

See also

  - https://wiki.archlinux.org/index.php/Session_lock
  - https://wiki.archlinux.org/index.php/Power_management#Sleep_hooks
