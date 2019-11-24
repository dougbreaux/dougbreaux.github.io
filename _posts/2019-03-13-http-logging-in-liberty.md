---
title: Enabling HTTP request/response logging in Liberty
tags: [ logging, docker, liberty, websphere ]
---
The following Liberty configuration, potentially added into the `configDropins` directory as a separate file, can be used to [enable HTTP request logging](https://www.ibm.com/support/knowledgecenter/en/SSEQTP_liberty/com.ibm.websphere.wlp.doc/ae/rwlp_http_accesslogs.html):

```xml
<server>  
  <featureManager>  
    <feature>monitor-1.0</feature>  
  </featureManager>  

  <httpEndpoint id="defaultHttpEndpoint">  
    <accessLogging filepath="/logs/http_defaultEndpoint_access.log" logFormat='%h %i %u %t "%r" %s %b' />  
  </httpEndpoint>  
</server>
```

If you haven't already installed the [monitor-1.0 feature](https://www.ibm.com/support/knowledgecenter/en/SSEQTP_liberty/com.ibm.websphere.wlp.doc/ae/twlp_monitor10.html), you'll first have to also:

`/opt/ibm/liberty/wlp/bin/installUtility install monitor-1.0`

(See [Editing files in Liberty Docker containers](https://www.ibm.com/developerworks/community/blogs/Dougclectica/entry/Editing_files_in_Liberty_Docker_containers_e_g_Trace_logging) if you're wanting to do this in a running Docker Liberty container.)
