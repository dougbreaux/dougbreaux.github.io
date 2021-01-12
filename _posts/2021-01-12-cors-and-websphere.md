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

We discovered, though, that for `content-type` `application/json`, `POST` requests were failing due to CORS restrictions. Apparently, that `content-type` triggers a "[CORS Preflight](https://en.wikipedia.org/wiki/Cross-origin_resource_sharing#Preflight_example)" request, which is an HTTP `OPTIONS` request. 

[Multiple](https://stackoverflow.com/a/29954326/796761) [references](https://stackoverflow.com/a/43881141/796761) pointed out this behavior, with a pointer to some [official Mozilla Developer Network (MDN) description](https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS#simple_requests).

This behavior was occuring for us in all the modern browsers we'd tried, so it wasn't just a quirk. Watching the network requests in the Firefox developer tools, we'd see the `OPTIONS` request sent and fail. (Chrome and Chromium Edge did not explicitly show the `OPTIONS` request, BTW, only the failed subsequent/overall request. And I want to say it was appearing as a `GET` instead of `POST` too, but I can't remember for certain.)

## HTTP `OPTIONS`

So the first step is to ensure that the HTTP `OPTIONS` verb is being allowed by all the web components down the chain (CDN, haproxy, IHS, WebSphere, application, etc.) If any of those are not allowing option you should see an [HTTP 405 "Method not allowed" response](https://www.w3.org/Protocols/rfc2616/rfc2616-sec10.html#sec10.4.6).

We did initially see 405s and had to adjust for that, but then we started seeing 403s on the OPTIONS request instead:
![cors-options-error.png]({{site.baseurl}}/assets/cors-options-error.png)

Now what? Attempting a plain `OPTIONS` request through a test tool (Postman) succeeded, so what was different?

## CORS Request Headers

Looking at all the request headers being sent by the failing browser case, there were a few related to CORS that I hadn't set in my Postman test case. Notably
- `Origin`
- `[Access-Control-Request-Headers](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Access-Control-Allow-Headers)`
- `Access-Control-Request-Method`

Once I added those, Postman started failing too. So now I had the simplest way to duplicate the problem. 

Ok, at least the `Origin` one should make sense. Our above (only partially-understood, clearly :wink:) IHS rule is looking for that header, so that would have be an essential one for CORS type requests.

I'll admit it was largely trial-and-error from here, but [some references](https://stackoverflow.com/a/32501365/796761), read carefully, might have clued me in that I'd need to also add the following IHS rule:
```apacheconf
        Header set Access-Control-Allow-Headers "content-type"
```

Although, in my defense, I had read that [certain request headers would be assumed to be allowed by default](https://developer.mozilla.org/en-US/docs/Glossary/CORS-safelisted_request_header), and `content-type` should have been one of those.

But what really clinched that one was that, in this case, the Chromium-Edge console gave the particularly helpful error:
```
Access to XMLHttpRequest at 'https://my-main-domain.com/address-validation/api/address/validate' from origin 'https://www.test-cors.org' has been blocked by CORS policy: Request header field content-type is not allowed by Access-Control-Allow-Headers in preflight response.
```

## WebSphere and (Java, Spring MVC) Service

But even with all that, we were still getting a 403 response frome the Preflight `OPTIONS`. Logged in the IHS access log, so we knew it was reaching that, but errors in our application (service) log or WebSphere log.

### IHS details

So I reached out to an IBM [IHS and WAS expert colleague Eric Covener](https://github.com/covener), who had me enable Apache Module "Request Handler" logging with `%{RH}e` (looking for official reference), which reported `mod_was_ap22_http.c/-2/handler`, which my colleague says that "-2" means the reponse was forwarded by WebSphere. Thus, this remaining 403 is coming from WebSphere and/or our service, not from IHS.

That is, `OPTIONS` is being passed down to WebSphere, which isn't handling it. It honestly seemed inconceivable to me that such a low-level detail (only if JSON, Preflight `OPTIONS` will be sent) would have to be explicitly handled by service logic, but apparently it is. 

### WebSphere details

Eric then suggested enabling WebSphere [Web Container "Must gather" tracing](https://www.ibm.com/support/pages/mustgather-web-container-and-servlet-engine-problems-websphere-application-server) to get further details of where in WebSphere the response was being generated.

Then another IBM colleague, [Phu Dinh](https://github.com/pmd1nh), looked at the resulting trace and pointed out that it was the Spring MVC Dispatcher Servlet that was returning the 403.

### Apache rules to handle `OPTIONS`

[One reference](https://benjaminhorn.io/code/setting-cors-cross-origin-resource-sharing-on-apache-with-correct-response-headers-allowing-everything-through/) suggested manually configuring Apache (IHS) to respond to `OPTIONS` with a 200, but that seems way too fiddly to me.

### Spring CORS Support

Next, our service developer had asked if we needed to be using [Spring's CORS support](https://spring.io/blog/2015/06/08/cors-support-in-spring-framework) (this is a Spring MVC web service), which I had originally thought no, but now looked like it might be the least objectionable option for us. Although I definitely didn't want to have to manually manage there the list of allowed domains. 

But before we pursued this approach further, our other developer found another reference that provided the solution we ended up using.

### Simple IHS rule to "absorb" `OPTIONS`

As described in [Configuring CORS for WebSphere Application Server](https://www.ibm.com/support/pages/node/6348518), adding this 

## References

- https://en.wikipedia.org/wiki/Cross-origin_resource_sharing
- https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS
- https://stackoverflow.com/a/1850482/796761
- https://stackoverflow.com/a/29954326/796761
- https://www.test-cors.org/ Very useful site for testing CORS on your server. Even provides a shareable link to your exact test case.
- [Configuring CORS for WebSphere Application Server](https://www.ibm.com/support/pages/node/6348518)
- [Enabling Cross Origin Requests for a RESTful Web Service](https://spring.io/guides/gs/rest-service-cors/) and [CORS support in Spring Framework](https://spring.io/blog/2015/06/08/cors-support-in-spring-framework) for Spring MVC
- https://benjaminhorn.io/code/setting-cors-cross-origin-resource-sharing-on-apache-with-correct-response-headers-allowing-everything-through/
- https://stackoverflow.com/a/32501365/796761
- https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Access-Control-Allow-Headers
- https://developer.mozilla.org/en-US/docs/Glossary/CORS-safelisted_request_header
- https://www.ibm.com/support/pages/mustgather-web-container-and-servlet-engine-problems-websphere-application-server
