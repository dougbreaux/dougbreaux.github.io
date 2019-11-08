---
title: Capturing Web Service (JAX-WS) messages in WebSphere
tags: [ soap, messages, web-services, trace, log websphere, xml, jax-ws ]
---
We wanted to capture some representative SOAP messages from our JAX-WS client Web Application (so that we could [mock up a test service using SoapUI](http://www.soapui.org/Getting-Started/mock-services.html)), and as it happens this is very easy to do with WebSphere trace settings.

## References

DeveloperWorks article [Troubleshooting JAX-WS applications with the WebSphere Application Server V6.1 Feature Pack for Web Services](http://www.ibm.com/developerworks/websphere/library/techarticles/0803_adams/0803_adams.html#Tracing%20SOAP%20messages) describes this, and other techniques, and at least this portion is still applicable to current versions of WebSphere.

[Tracing web services](http://www-01.ibm.com/support/knowledgecenter/SSAW57_8.5.5/com.ibm.websphere.nd.multiplatform.doc/ae/twbs_tracewbscomp.html) is the reference Knowledge Center article for WebSphere 8.5.5.

## Enable Trace

Using option 4 from that Knowledge Center article, on the WebSphere console, go to **Troubleshooting** > **Logs and trace** > ServerName > **Change log detail levels**

[![image](https://www.ibm.com/developerworks/community/blogs/Dougclectica/resource/BLOGS_UPLOADED_IMAGES/Capture.PNG)](https://www.ibm.com/developerworks/community/blogs/Dougclectica/resource/BLOGS_UPLOADED_IMAGES/Capture.PNG)

Then add the string "**com.ibm.ws.websvcs.trace.*=all**" (the colon is the separator between multiple log strings being traced).

Or drill down via the "**Components and Groups**" selection list:

[![image](https://www.ibm.com/developerworks/community/blogs/Dougclectica/resource/BLOGS_UPLOADED_IMAGES/Capture2.PNG)](https://www.ibm.com/developerworks/community/blogs/Dougclectica/resource/BLOGS_UPLOADED_IMAGES/Capture2.PNG)

## Trace Data

By default, the trace data is logged to **${SERVER_LOG_ROOT}/trace.log**, where ${SERVER_LOG_ROOT} is the same location of the JVM logs, typically **...profiles/ProfileName/logs/ServerName**.

You can see and change this location in the console at **Troubleshooting** > **Logs and trace** > ServerName > **Diagnostic Trace**, in the **File Name** field.

When you look in this file, you will see XML dumps of incoming and outgoing JAX-WS messages.

Don't forget to disable trace when you're finished capturing and need to optimize for normal Production use.
