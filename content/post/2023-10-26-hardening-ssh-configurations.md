---
title: Hardening SSH configurations
date: 2023-10-26T00:00:00+01:00
tags:
  - Security
  - Encryption
  - SSH
---


Install `ssh-audit`:

```sh
pacman -S ssh-audit
```


## Server

Audit the current server configuration:

```sh
ssh-audit localhost
```

If any `fail` or `warn` level log line appear, try implementing the following
sections.


### Explicitly allow only selected algorithms

Restrict key exchange algorithms, ciphers, message authentication codes, and
asymmetric keys:

```
# File: /etc/ssh/sshd_config.d/01-ssh-audit_hardening.conf
# Restrict key exchange, cipher, and MAC algorithms, as per sshaudit.com
# hardening guide.
KexAlgorithms sntrup761x25519-sha512@openssh.com,curve25519-sha256,curve25519-sha256@libssh.org,diffie-hellman-group16-sha512,diffie-hellman-group18-sha512,diffie-hellman-group-exchange-sha256
Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com,aes256-ctr,aes192-ctr,aes128-ctr
MACs hmac-sha2-256-etm@openssh.com,hmac-sha2-512-etm@openssh.com,umac-128-etm@openssh.com
HostKeyAlgorithms ssh-ed25519,ssh-ed25519-cert-v01@openssh.com,sk-ssh-ed25519@openssh.com,sk-ssh-ed25519-cert-v01@openssh.com,rsa-sha2-512,rsa-sha2-512-cert-v01@openssh.com,rsa-sha2-256,rsa-sha2-256-cert-v01@openssh.com
```

### Force usage of public key authentication and prevent root login

```
# File: /etc/ssh/sshd_config.d/999-override.conf
# Manual configuration

## Security hardening
## Note that some of these overlap each other.

### Disable root login
PermitRootLogin no

### Disable clear text passwords
PasswordAuthentication no

### Disable empty passwords
PermitEmptyPasswords no

### Disable s/key passwords
KbdInteractiveAuthentication no

### Only allow public key authentication
AuthenticationMethods publickey
PubkeyAuthentication yes
```


### Only allow large DH moduli


```sh
cd /etc/ssh
awk '$5 >= 3071' moduli > moduli.safe
cp -l moduli moduli.bak
mv moduli.safe moduli
```

## Client

Audit the current client configuration:

```sh
ssh-audit -c --port 1234 &
ssh localhost -p 1234
```


### Explicitly allow only selected algorithms

Restrict key exchange algorithms, ciphers, message authentication codes, and
asymmetric keys:

```
# File: ~/.ssh/config

Host *
    Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com,aes256-ctr,aes192-ctr,aes128-ctr
    KexAlgorithms sntrup761x25519-sha512@openssh.com,curve25519-sha256,curve25519-sha256@libssh.org,diffie-hellman-group16-sha512,diffie-hellman-group18-sha512,diffie-hellman-group-exchange-sha256
    MACs hmac-sha2-256-etm@openssh.com,hmac-sha2-512-etm@openssh.com,umac-128-etm@openssh.com
    HostKeyAlgorithms sk-ssh-ed25519-cert-v01@openssh.com,ssh-ed25519-cert-v01@openssh.com,sk-ssh-ed25519@openssh.com,ssh-ed25519,rsa-sha2-512-cert-v01@openssh.com,rsa-sha2-256-cert-v01@openssh.com,rsa-sha2-512,rsa-sha2-256
```
