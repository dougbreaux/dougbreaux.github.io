---
published: true
title: Improved PuTTY Proxying
tags:
  - putty
  - ssh
  - tunnel
  - proxy
---
[PuTTY 0.77 introduced some new proxy capabilities](https://www.chiark.greenend.org.uk/~sgtatham/putty/changes.html) (2022-05-07) that simplify setting up a "jump" host. 

> Major improvements to network proxy support:
- Support for interactively prompting the user if the proxy server requires authentication.
- Built-in support for proxying via another SSH server, so that PuTTY will SSH to the proxy and then automatically forward a port through it to the destination host. (Similar to running plink -nc as a subprocess, but more convenient to set up, and allows you to answer interactive prompts presented by the proxy.)
- Support for HTTP Digest authentication, when talking to HTTP proxies.

Note, in particular, this removes the need for `plink` and its command-line options, as described in [SSH key authentication with PuTTY, Part 2, Tunneling with Plink]({% post_url 2011-02-03-tunneling-with-plink %}).

![PuTTY-with-SSH-proxy.png]({{site.baseurl}}/assets/PuTTY-with-SSH-proxy.png)

See [The Proxy Panel](https://the.earth.li/~sgtatham/putty/0.77/htmldoc/Chapter4.html#config-proxy) online help.

Update: Proxy types now a drop-down list, instead of radio-buttons, in PuTTY 0.78:
![0.78 Proxy Panel]({{site.baseurl}}/assets/PuTTY-proxy-78.png)

