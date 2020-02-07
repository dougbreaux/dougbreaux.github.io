---
title: SSH Tunneling with a manual first hop
tags: [ ssh, tunnel, 2fa, keys, pci, duo, putty, windows ]
---
Follow-up to:
1. [SSH key authentication with PuTTY]({% post_url 2011-02-03-ssh-key-authentication-with-putty %})
2. [SSH key authentication with PuTTY, Part 2, Tunneling with Plink]({%post_url 2011/02/03/tunneling-with-plink %})
3. [SSH Tips]({% post_url 2018-02-01-ssh-tips %})

What if that first hop doesn't allow you to background tunnel through it? Either because SSH key authentication isn't enabled, or because it uses a 2FA solution that requires manual interaction?

Thanks to colleague Dan Patterson, I've got steps that work out almost as quickly/simply as I had before.

## First hop with manual authentication and primary tunnel

First, I'm opening a [PuTTY](https://www.putty.org/) session to the "jump" host where I have to both use a password rather than a key, and where I have to authorize 2FA through [Duo](https://duo.com/product/multi-factor-authentication-mfa/two-factor-authentication-2fa).

The PuTTY Session "Host Name" and "Port" are to the server I have to reach in order to then reach the other desired destinations. The server that requires password authentication and/or manual 2FA interaction. I'll call this the "_jump host_".

_TODO: PuTTY screenshot_

Then, in the **Connection** > **SSH** > **Tunnels** configuration, I'm going to tunnel local 2222 to the SSH port (normally 22) on a host in a network on the other side of the _jump host_. Let's call that the "_protected network_", and the "_tunnel host_".

_TODO: PuTTY screenshot_

Under **Connection**, I'm also setting a "keealive" on this PuTTY session so that it will stay open even though I won't be interacting with it.

_TODO: PuTTY screenshot_

Login (to the _jump host_), fullfill the 2FA requirements, put the window somewhere you won't close it. (I also gave it a unique size and font color to remind myself that it's special.)

## PuTTY Session for dynamic/on-the-fly to the _protected network_

Now we can use the above connection to tunnel, in one step, to another host in the _protected network_ (technically, anything reachable from that _tunnel host_, including perhaps other hosts that only it can reach, like via a VPN).

I've created another PuTTY Session for this, with no hostname specified, so that I can type in any host dynamically when I open it.

_TODO: PuTTY screenshot_

I've named the Session "localhost 2222 proxy" to let me know that I'm going to be connecting through the above tunnel.

Now, here I'm using the same local proxy "plink" approach as described earlier, but with the proxy host being said localhost:2222.

_TODO: PuTTY screenshot_

The small addition needed to the prior plink command was the -P one for the custom port:

```
c:\Program Files (x86)\PuTTY\plink %proxyhost -P %proxyport -nc %host:%port
```

## Single Session with many tunneled ports

Finally, my "big" PuTTY session which automatically sets up many different tunneled ports for me, including database server ports and [the super-useful dynamic port that I can use as a browser SOCKS proxy](/2018/02/01/ssh-tips.html#dynamic-forwarding).

I used a hardcoded destination in the _protected network_, but that's not required.

_TODO: PuTTY screenshot_

Same proxy setup as above:

_TODO: PuTTY screenshot_

But also now my tunneled ports:

_TODO: PuTTY screenshot_

## Notes

_TODO: Discussion about PCI something-you-know/something-you-have_
