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

## JSON Request Data

The above was sufficient for our prior use cases, all of which were either HTTP `GET`s or `POST`s of `content-type` `application/x-www-form-urlencoded`.

We discovered, though, that for `content-type` `application/json`, `POST` requests were failing due to CORS restrictions. Apparently, that `content-type` triggers a "[CORS Preflight](https://en.wikipedia.org/wiki/Cross-origin_resource_sharing#Preflight_example)" request, which is an HTTP `OPTIONS` request. (I've so far found multiple [references](https://stackoverflow.com/a/43881141/796761) confirming this behavior, but not yet any official statement on why.)

This behavior was occuring for us in all the modern browsers we'd tried, so it wasn't just a quirk.

## HTTP `OPTIONS`

So the first step was to ensure that the HTTP `OPTIONS` verb is being allowed by 