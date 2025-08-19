---
date: 2025-05-21T00:00:00Z
title: "Configure `resolvectl`"
tags:
  - Arch Linux
  - DNS
  - Forwarding
  - Network
  - resolvectl
  - sytemd-resolved
---

Configure your favorite DNS servers with `systemd-resolved`.

<!--more-->

```ini
# file: /etc/systemd/resolved.conf
...
[Resolve]
# SEE: https://git.fdn.fr/fdn-public/wiki/-/blob/master/support/faq/config_dns.md
DNS=80.67.169.12#ns0.fdn.fr 2001:910:800::12#ns0.fdn.fr
FallbackDNS=80.67.169.40#ns1.fdn.fr 2001:910:800::40#ns1.fdn.fr
DNSOverTLS=yes
```

Enable and start it
```sh
systemctl enable --now systemd-resolved
```

Test it works
```sh
resolvectl query go.dnscheck.tools
```

Disable `dhcpcd`/`resolvconf` integration.

```ini
# file: /etc/dhcpcd.conf
...
nohook resolv.conf
```

Enable `systemd-resolved`'s stub resolver

```sh
cp /etc/resolv.conf{,.bak}
cp /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf
```

Test it works
```sh
dig go.dnscheck.tools
```

Should reply with
```console
...
;; SERVER: 127.0.0.53#53(127.0.0.53) (UDP)
...
```

Once you have tested this works and restarted your machine at least once,
checking `resolv.conf` does not get overwritten by `dhcpcd`, you
can link it instead.

```sh
ln -sf ../run/systemd/resolve/stub-resolv.conf /etc/resolv.conf
```
