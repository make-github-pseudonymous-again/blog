---
date: 2025-05-21T00:00:00Z
title: "Proxy DNS on Arch Linux with `unbound` and `resolvectl`"
tags:
  - Arch
  - DNS
  - Proxying
  - Forwarding
  - Network
  - unbound
  - systemd-resolved
---

Configure your favorite DNS servers with `unbound`.

<!--more-->

We assume you already have `systemd-resolved` set up.

Install `unbound` and `expat`

```sh
pacman -S unbound expat
```

Configure `server#interface` and `server#access-control` in `/etc/unbound/unbound.conf`.

Configure `forward-zone`:

```yml
forward-zone:
        name: "."
        forward-tls-upstream: yes
        forward-addr: 2001:910:800::12#ns0.fdn.fr
        forward-addr: 2001:910:800::40#ns1.fdn.fr
        forward-addr: 80.67.169.12#ns0.fdn.fr
        forward-addr: 80.67.169.40#ns1.fdn.fr
```

Enable and start `unbound.service`:

```sh
systemctl enable --now unbound
```

Configure `systemd-resolved` to forward DNS queries to `unbound`:

```ini
# /etc/systemd/resolved.conf
[Resolve]
# NOTE: Forward to unbound.
DNSStubListener=no
DNS=127.0.0.1#53
DNSOverTLS=no
Domains=~.
```

Restart `systemd-resolved`:

```sh
systemctl restart systemd-resolved
```

See also:
  - https://wiki.archlinux.org/title/Unbound#Forwarding_queries
  - https://wiki.archlinux.org/title/Unbound#Testing_validation
