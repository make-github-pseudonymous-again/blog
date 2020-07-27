---
date: 2018-04-05T00:00:00Z
title: Setup your calendar with Nextcloud on Arch Linux
---

Ever wanted to get rid of your dependency on Google Calendar?

<!--more-->

[Install Nextcloud by following the instruction
here](/2018/04/05/host-your-files-at-home-with-nextcloud/).

Install the `nextcloud-app-calendar` package:

	pacman -S nextcloud-app-calendar

Login as admin on your nextcloud instance, go to `settings > applications >
disabled` and enable the Calendar app.
