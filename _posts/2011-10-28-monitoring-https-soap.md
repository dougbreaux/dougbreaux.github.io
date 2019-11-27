---
title: Monitoring https SOAP requests
tags: [soap,monitor,soapui,proxy,http,https,websphere,ssl]
---
## The Scenario

I've been trying to connect to a customer's Web Service (from within WebSphere 6.1, but that's a different topic) and having some problems getting the security to work (another different topic), so I've desperately wanted an https-capable traffic monitor/proxy.

After trying the one built into RAD (which successfully passes the https requests, but displays them as encrypted garbage), Apache tcpmon (no SSL), membrane-monitor (seemed to not respond at all and I couldn't tell why), and Wireshark (looked too tedious to get working with SSL), I eventually got [soapUI](http://www.soapui.org/)'s [HTTP Monitor](http://www.soapui.org/SOAP-Recording/recording-soap-trafic.html) working, although not without some non-obvious setup there either. So I'm going to document that setup here.

## Trust the Service Endpoint

First, you'll need a jks TrustStore where you can place the public key of the server which hosts the https-protected Service you're going to call. You can use a tool like the GUI [ikeyman](https://www.ibm.com/support/knowledgecenter/SSYKE2_8.0.0/com.ibm.java.security.component.80.doc/security-component/ikeyman.html), included with WebSphere, or the command-line [keytool](http://download.oracle.com/javase/6/docs/technotes/tools/windows/keytool.html), included with your JRE, to do this.

## Launch the HTTP Monitor

Next, it seemed fairly obvious what to do in soapUI. Right-click on a project and "Launch HTTP Monitor". You're presented with the following dialog:

[![image](/assets/soapuitcpmonitor.jpg)](/assets/soapuitcpmonitor.jpg)

To do https/SSL, you need to select **HTTP Tunnel** rather than **HTTP Proxy**. Set the Port to the local port your client is going to hit, and the endpoint to the remote service URL you're ultimately calling.

Then go to the Security tab:

[![image](/assets/soapuitcpmonitor2.jpg)](/assets/soapuitcpmonitor2.jpg)

Initially, all I had was the aforementioned TrustStore configured here in the **HTTP tunnel - TrustStore** and **TrustStore Password** fields. This allows the HTTP Monitor to talk SSL _to the remote Service_.

### Something Amiss

However, when I started the monitor with those settings, I received a cryptic dialog, "**Error starting monitor: C:\Program Files(x86)\SmartBear\soapUI-4.0.1\bin (Access is denied)**":

[![image](/assets/soapuitcpmonitorerror.jpg)](/assets/soapuitcpmonitorerror.jpg)

I suspected Windows authority problems or path problems, but nothing seemed to resolve those, so I tried running the soapui.bat script from a command-prompt rather than the soapUI desktop shortcut, and then I saw the following prompts:

```
jetty.ssl.password :
jetty.ssl.keypassword :
```

Ahah! Google does find [something relevant](https://community.smartbear.com/t5/SoapUI-Open-Source/prompt-for-jetty-ssl-username-and-password-in-stdout-when/m-p/7576) there.

## HTTP Monitor Server Certificate

HTTP Monitor needs its own SSL certificate (private key) and KeyStore in order to also talk SSL _to your client application_, which I should have realized. Then, of course, your client environment will have to import the public portion of that certificate into its TrustStore as well. But the less obvious detail is that this private key must use the alias "jetty" (as soapUI is using the Jetty server under the covers).

So again using keytool (or ikeyman), this time to generate a private/public key certificate pair with the alias "jetty", create the KeyStore that is referenced in the **HTTP tunnel - KeyStore**, **Password**, and **KeyPassword** fields. (Note the two properties listed in the prompts above.) Here's the keytool command I actually used:

`jre\bin\keytool -genkeypair -alias jetty -keystore soapui.jks`

Now complete the remaining Security fields and click "OK":

[![image](/assets/soapuitcpmonitor3.jpg)](/assets/soapuitcpmonitor3.jpg)

You'll have an SSL Tunnel listening on your local port, and you'll be able to see SOAP requests and responses sent through that local URL.
