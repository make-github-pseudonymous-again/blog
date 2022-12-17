+++
date: 2022-02-22T00:00:00Z
title: Forward port on Arch Linux
tags:
  - Arch Linux
  - Port forwarding
  - Network
draft: true
+++

Following https://www.digitalocean.com/community/tutorials/how-to-forward-ports-through-a-linux-gateway-with-iptables

First [enable packet forwarding](https://wiki.archlinux.org/title/Internet_sharing#Enable_packet_forwarding).
Write the following to `/etc/sysctl.d/30-ipforward.conf` then reboot.

```
net.ipv4.ip_forward=1
net.ipv6.conf.default.forwarding=1
net.ipv6.conf.all.forwarding=1
```

Then configure, enable, and start iptables.

```console
EXT=<packet origin network>
PORT=<packet origin port>
INT=<destination network>
SRC=<source IP address on destination network>
DEST=<destination IP address on destination network>
sudo iptables -A FORWARD -i $EXT -o $INT -p tcp --syn --dport $PORT -m conntrack --ctstate NEW -j ACCEPT
sudo iptables -A FORWARD -i $EXT -o $INT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
sudo iptables -A FORWARD -i $INT -o $EXT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
sudo iptables -t nat -A PREROUTING -i $EXT -p tcp --dport $PORT -j DNAT --to-destination $DEST
sudo iptables -t nat -A POSTROUTING -o $INT -p tcp --dport $PORT -d $DEST -j SNAT --to-source $SRC
sudo iptables-save -f /etc/iptables/iptables.rules
sudo systemctl enable --now iptables
```

TODO ipv6:
  - https://jensd.be/1086/linux/forward-a-tcp-port-to-another-ip-or-port-using-nat-with-nftables
  - https://serverfault.com/a/417278
  - https://wiki.gentoo.org/wiki/Nftables/Examples
