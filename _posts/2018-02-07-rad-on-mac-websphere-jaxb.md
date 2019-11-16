---
title: "RAD on Mac: WebSphere and JAXB"
tags: [ websphere,mac, jaxb, rad, liberty ]
---
After [getting RAD running on my MacBook](https://www.ibm.com/developerworks/community/blogs/Dougclectica/entry/Running_RAD_on_a_Mac), I hit [a couple of issues trying to generate JAXB classes from an XML Schema](https://developer.ibm.com/answers/questions/429511/generate-java-classes-from-xsd-in-rad-on-mac.html).

While that second link really contains all the crucial information on those issues, I thought I'd also post it here.

## WebSphere Liberty Core(?)

First, my RAD install came with an installation of WebSphere Liberty, I think "Core" Edition. ([Liberty Features](https://www.ibm.com/support/knowledgecenter/en/SSEQTP_liberty/com.ibm.websphere.wlp.doc/ae/rwlp_feat.html) compares the Editions.)

## JAXB

And that didn't come with very many Features to enable. I didn't notice this until I went to generate JAXB Java classes from an XML Schema (XSD) file. Where I got the error:
```
 Errors occurred during wsgen.  

     java.io.IOException: Cannot run program "/opt/IBM/WebSphere/Liberty/bin/jaxb/xjc" (in directory "/opt/IBM/WebSphere/Liberty"): error=2, No such file or directory</span>
```
(Interesting, didn't even know I was using wsgen, eh?)

Well, that is the correct location of my Liberty install. But, hey, there is no jaxb folder there at all. I have a couple of other xjc instances on the system, but I have no idea how to make RAD use them. My project is a Web Project, pointed at a JRE that does have xjc, and the Liberty Runtime, but apparently that's not sufficient for the RAD configuration to connect the dots.

## Liberty for Developers

So instead I uninstalled that copy of Liberty (with Installation Manager), and then added to Installation Manger the "IBM WebSphere Application Server Liberty for Developers (ILAN)" repository, from [WebSphere Application Server product offerings for supported operating systems](https://www.ibm.com/support/knowledgecenter/SSEQTP_8.5.5/com.ibm.websphere.installation.base.doc/ae/cins_offerings.html). (One of the few available for Mac OS.)

The ILAN versions are available for free with a DeveloperWorks ID and have the caveat:

> This offering is a no-cost non-supported and non-warranted version of the product.

This one let me install all kinds of Features, including ... JAXB support. Now the xjc tool is there where RAD wanted it.

## "jar" access is not allowed

Except, now RAD generating JAXB from Schema produced the following error:
```
The xjc tool returned an error:  
 parsing a schema...  
 java.lang.AssertionError: org.xml.sax.SAXParseException: Failed to read external schema document "jar:file:/opt/IBM/WebSphere/Liberty/lib/com.ibm.ws.jaxb.tools.2.2.10_1.0.19.jar!/com/sun/tools/xjc/reader/xmlschema/bindinfo/xjc.xsd", because "jar" access is not allowed.</span>
```
Also, it turns out I only got this message if I elected for the code-generation process to create Serializable classes. If I didn't select that option, the generation succeeded. Weird since I the only difference I noticed - after I got it working - is adding "implements Serializable" to the generated classes.

In any case, this StackOverflow link pointed at a very similar problem, with a definitely non-intuitive workaround, that eventually succeeded when I found the right place for it:

[https://stackoverflow.com/questions/23011547/webservice-client-generation-error-with-jdk8](https://stackoverflow.com/questions/23011547/webservice-client-generation-error-with-jdk8)

For me, this meant going to the /opt/IBM/WebSphere/Liberty/bin/jaxb/xjc script (good thing it was a script and not a compiled executable), and adding the following lines, as the last step that touches JVM_ARGS before it's used:
```
# ... because "jar" access is not allowed"  
JVM_ARGS="-Djavax.xml.accessExternalSchema=all ${JVM_ARGS}"
```

### Update: Not just Mac + Liberty

Now back on my primary Windows 10, with WebSphere 8.5.5 Full Profile, I had the same problem occur:

```
The Xjc tool has completed Web service artifact generation.  
Review the tool output for details, including errors and warnings.  
parsing a schema...  
java.lang.reflect.InvocationTargetException  
at sun.reflect.NativeMethodAccessorImpl.invoke0(Native Method)  
at sun.reflect.NativeMethodAccessorImpl.invoke(NativeMethodAccessorImpl.java:90)  
at sun.reflect.DelegatingMethodAccessorImpl.invoke(DelegatingMethodAccessorImpl.java:55)  
at java.lang.reflect.Method.invoke(Method.java:508)  
at com.ibm.ws.bootstrap.WSLauncher.main(WSLauncher.java:280)  
Caused by: java.lang.AssertionError: org.xml.sax.SAXParseException: Failed to read external schema document "jar:file:/C:/Program Files (x86)/IBM/WebSphere/AppServer/plugins/com.ibm.jaxb.tools.jar!/com/ibm/jtc/jax/tools/xjc/reader/xmlschema/bindinfo/xjc.xsd", because "jar" access is not allowed.</span>
```

Same fix/workaround, this time in `C:/Program Files (x86)/IBM/WebSphere/AppServer/bin/xjc.bat`, in case that helps anyone searching later.

(And yes, this seems to me like a bug in either RAD/WDT, or WebSphere, or the combination.)
