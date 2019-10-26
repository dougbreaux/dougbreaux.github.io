---
title: Using IBM HTTP Server 6.1 diagnostic capabilities with WebSphere
tags: [ihs,diagnostic,websphere,httpd,mod_status,plugin,debugging,apache]
---
[Using IBM HTTP Server 6.1 and later diagnostic capabilities with WebSphere](http://publib.boulder.ibm.com/httpserv/ihsdiag/WebSphere61.html)

This could be useful. Apache mod_status is available in IHS, and when it's enabled it provides information about the individual threads running under the httpd processes.

The information is provided as a simple web page via a URL (that of course can be protected by any of the various Apache mechanisms).

With the default httpd.conf file, only the following changes are required:

1.  Uncomment the module loading:  

    `LoadModule status_module modules/mod_status.so`

2.  Uncomment the Location setup:

    ```xml
    <Location /server-status>  
        SetHandler server-status  
        Order deny,allow  
        Deny from all  
        Allow from .example.com  
    </Location>
    ```

3.  Change the Allow rule to your own domain or IP, or protect the URL with HTTP Basic Auth, or something else.
