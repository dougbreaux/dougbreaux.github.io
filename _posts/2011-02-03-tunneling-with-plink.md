---
title: SSH key authentication with PuTTY, Part 2: Tunneling with Plink 
tags: [pageant,ssh,putty,windows,authentication,security,unix]
---
Following up on [Part 1](/2011/02/03/ssh-key-authentication-with-putty.html), here's an additional tip which I use frequently. That is, when I need to tunnel SSH through one machine to reach others, using a background proxy with SSH key authentication for the initial connection simplifies this 2-hop process.  

## Automatic proxying with Plink

The PuTTY installation also includes a command-line SSH program called [Plink](http://the.earth.li/%7Esgtatham/putty/0.60/htmldoc/Chapter7.html#plink) which can be used in a "background" mode. The PuTTY help describes how to use Plink as a local proxy program, creating a background tunnel for the main PuTTY window. This configuration is performed in the **Window** > **Proxy** tab:

[![image](https://dw1.s81c.com/developerworks/mydeveloperworks/blogs/Dougclectica/resource/PuTTYPlinkProxy.png)](https://www.ibm.com/developerworks/mydeveloperworks/blogs/Dougclectica/resource/PuTTYPlinkProxy.png)

<div>Specify a **Proxy type** of local, and the standard SSH **Port**, 22.  
</div>

In the **Proxy hostname** field, you enter a host to which you have direct access and on which you've configured key authentication, then you refer to that host via the **%proxyhost** variable in the plink command you provide as the local proxy:

<pre>\path\to\plink -l %user %proxyhost -nc %host:%port</pre>

The **%host** and **%port** variables represent the ultimate destination **Host Name** and **Port** fields from the main PuTTY **Session** tab (which, as usual, you can enter as needed or save under separate Sessions for each server).

**%user** and **%proxyhost** are from this configuration page.  

**Note:** If your **Default Settings** PuTTY profile has a username (on the **Connection** > **Data** tab) or hostname configured in it, [plink will use those automatically](http://superuser.com/questions/204985/plink-takes-connection-host-from-puttys-default-connection). Discovering that wasted a couple of hours for myself and a colleague. On the other hand, if the configured default username matches your username on the proxy server, you can completely omit the -l parameter from the plink command.  

## Tunneling additional Ports

Furthermore, this technique can be used in conjunction with "normal" SSH tunneling (**Connection** > **SSH** > **Tunnels**) in order to tunnel a localhost port through both hops. For instance, to tunnel the default WebSphere Application Server administration console port:

[![image](https://dw1.s81c.com/developerworks/mydeveloperworks/blogs/Dougclectica/resource/BLOGS_UPLOADED_IMAGES/sshtunnel.png)](https://www.ibm.com/developerworks/mydeveloperworks/blogs/Dougclectica/resource/BLOGS_UPLOADED_IMAGES/sshtunnel.png)

Then you connect your browser to https://localhost:9043\. _(Don't forget to click **Add** for each port you want to tunnel.)_

You can similarly 2-hop tunnel X-Windows by enabling **X11 Forwarding** on PuTTY's **Connection > SSH > X11** tab. _(You'll need Windows X server like [XMing](http://www.straightrunning.com/XmingNotes/).)_

### Feedback?

Any additional tips you've found useful? Better ways to accomplish these same tasks? I welcome your comments and suggestions.
