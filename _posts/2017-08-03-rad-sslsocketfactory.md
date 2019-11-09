---
title: RAD and "Cannot find the specified class com.ibm.websphere.ssl.protocol.SSLSocketFactory"
tags: [	rsa, sdk, rad, was, eclipse, marketplace, websphere, ssl, wdt, plugins, https ]
---
### Missing IBM Websphere SSL class

I was simply trying to install an Eclipse plugin from the Eclipse Marketplace into my RAD on one system and RSA on another, but I kept getting this error:

> An error occurred while collecting items to be installed  
> session context was:(profile=IBM Software Delivery Platform com.ibm.sdp.eclipse.ide, phase=org.eclipse.equinox.internal.p2.engine.phases.Collect, operand=, action=).  
> Unable to read repository at https://github.com/iloveeclipse/anyedittools/releases/download/2.7.0/de.loskutov.anyedit.AnyEditTools_2.7.0.201705171641.jar.  
> java.lang.ClassNotFoundException: Cannot find the specified class com.ibm.websphere.ssl.protocol.SSLSocketFactory

Some web searches find that text. After a few unsuccessful attempts, the "alternative" solution from [Cannot find the specified class com.ibm.websphere.ssl.protocol.SSLSocketFactory](http://www-01.ibm.com/support/docview.wss?uid=swg21584437) did the trick:

> **Another workaround if using RAD or WDT versions 8.0.x or later** is to close the Servers view, exit RAD, then launch RAD again. Once RAD is restarted, retry the action that was failing previously. This workaround prevents the WAS SSL connection from being initialized first which should prevent the WAS SSL socket factory from being set as the default. Other SSL connections will attempt to use the RAD JDK's default socket factory unless otherwise specified.

I guess RAD started and loaded up the WAS SSL support, but RAD itself isn't fully able to use that.

Note also the warning to "reverse" that activity if you want to run WAS again under RAD.

### Relevant but not successful

*   [Problems working with a secured server using SSL connections](https://www.ibm.com/support/knowledgecenter/SSHR6W/com.ibm.websphere.wdt.doc/topics/rssl_isUseIBMSSLSocketFactory.htm?cp=SSHR6W_8.5.5)- seems to be an outdated approach. Also the first approach listed in the prior article
*   I tried changing the RAD JRE java.security property to put the "Sun" provider first, but it actually had the original problem as well.
