---
published: true
title: SSH Jump Hosts
tags:
  - ssh
  - tunnel
  - jump
  - proxy
---
Small addition to prior SSH tips, using [SSH Jump hosts](https://wiki.gentoo.org/wiki/SSH_jump_host).

Follow-up to:
1. [SSH key authentication with PuTTY]({% post_url 2011-02-03-ssh-key-authentication-with-putty %})
2. [SSH key authentication with PuTTY, Part 2, Tunneling with Plink]({% post_url 2011-02-03-tunneling-with-plink %})
3. [SSH Tips]({% post_url 2018-02-01-ssh-tips %})
4. [SSH Tunneling with a manual first hop]({% post_url 2020-02-07-ssh-hop-with-manual-login %})

From command-line (including Git Bash on Windows):
```console
$ ssh -J jump-server-user@jump.mydomain.com \
-D8888 \
-L2222:any-protected.mydomain.com:22 \
protected-server-user@any-protected.mydomain.com
```
