---
published: false
title: Improved PuTTY Proxying
tags:
  - putty
  - ssh
  - tunnel
  - proxy
---
## PuTTY proxy improvements

[PuTTY 0.77 introduced some new proxy capabilities](https://www.chiark.greenend.org.uk/~sgtatham/putty/changes.html) (2022-05-07) that simplify setting up a "jump" host. 

> Major improvements to network proxy support:
- Support for interactively prompting the user if the proxy server requires authentication.
- Built-in support for proxying via another SSH server, so that PuTTY will SSH to the proxy and then automatically forward a port through it to the destination host. (Similar to running plink -nc as a subprocess, but more convenient to set up, and allows you to answer interactive prompts presented by the proxy.)
- Support for HTTP Digest authentication, when talking to HTTP proxies.

Note, in particular, this removes the need for `plink` and its command-line options, as described in {% post_url 2011-02-03-tunneling-with-plink %}

![PuTTY-with-SSH-proxy.png]({{site.baseurl}}/assets/PuTTY-with-SSH-proxy.png)
