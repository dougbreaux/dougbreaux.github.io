---
published: false
title: CORS and WebSphere
tags:
  - websphere
  - cors
  - javascript
  - ajax
  - json
  - rest
  - spring
  - apache
  - ihs
  - httpd
---
## Cross-origin Resource Sharing

I won't try to [explain CORS](https://en.wikipedia.org/wiki/Cross-origin_resource_sharing), but in summary, browsers, by default, don't allow JavaScript to make HTTP requests to domains other than the one the JavaScript was loaded from, and CORS is a way for servers to say that some domains are expected to make such "cross-origin" requests to them.

## Using Apache configuration to add CORS headers

In our WebSphere ("Traditional" version 8.5.5) with IBM HTTP Server (IHS, based on Apache 2.2), we'd set up a few necessary headers in our IHS configuration using the Apache approach described in a number of places, like [here](https://stackoverflow.com/a/1850482/796761).

```apacheconf
    <IfModule mod_headers.c>
        SetEnvIf Origin "http(s)?://.*(my-other-domain1.com|my-other-domain2.com)(:[0-9]+)?$" AccessControlAllowOrigin=$0
        Header add Access-Control-Allow-Origin %{AccessControlAllowOrigin}e env=AccessControlAllowOrigin
        Header add Vary Origin
    </IfModule>
```

## 
