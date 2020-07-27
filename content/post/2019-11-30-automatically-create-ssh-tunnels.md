---
title: "Automatically Create SSH Tunnels"
date: 2019-11-30T00:29:10+01:00
tags:
  - Automation
  - Security
  - SSH
  - Tunnel
  - systemd
---


Use autossh and a systemd service...

<!--more-->

See [tunnel](https://github.com/aureooms/dotfiles/blob/master/.bin/tunnel)
and
[tunnel@.service](https://github.com/aureooms/dotfiles/blob/master/.config/systemd/user/tunnel%40.service).

For instance

    tunnel enable --now -R 12345:localhost:6789 example.com
