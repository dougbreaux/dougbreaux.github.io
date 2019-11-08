---
title: JAX-RS in WebSphere to accept uploaded files
tags: [ .net, upload, internet-explorer, jax-rs, http, c#, file, websphere, rest, wink ]
---
We've recently had a need to accept files submitted by a partner and perform some processing on them, with the partner returning later to retrieve the results. Rather than the "old", standard approach of using something like sftp and regularly kicking off a cron job to look for input files, this seemed like a good case for a Web Service.

And IMO REST style services are simpler to produce (particularly with standard APIs like JAX-RS), consume, and [test](http://www.soapui.org/rest-testing/getting-started.html), and further are a good fit for this particular scenario. (See the excellent book [RESTful Web Services](http://restfulwebapis.org/rws.html), now available for free in electronic form, or its successor, which I didn't realize existed.)

* TOC
{:toc}

## Design

I decided to support the URL "/batch", as an [HTTP POST](http://www.w3.org/Protocols/rfc2616/rfc2616-sec9.html#sec9.5) of standard ["multipart/form-data" media type](http://docs.oracle.com/javaee/6/api/javax/ws/rs/core/MediaType.html#MULTIPART_FORM_DATA), with a service-generated "Batch ID" (among other things) returned to the caller, and the URL "/batch/{batchId}" as an [HTTP GET](http://www.w3.org/Protocols/rfc2616/rfc2616-sec9.html#sec9.3) to obtain the results. (Both very easy to test directly from a browser, BTW. But also do seem the correct fit for the REST philosophy.)

I should say, I decided to _propose_ this approach and then go see if I could make it happen in a straightforward way. I wasn't sure if submitting files this way was normal enough to be easily supported by JAX-RS and/or WebSphere.

## Implementation

It turns out this is supported by JAX-RS in WebSphere, with a few different mechanisms. Right there in the official IBM Knowledge Center documentation, (almost) everything I needed to know:

[Configuring a resource to receive multipart/form-data parts from an HTML form submission](https://www-01.ibm.com/support/knowledgecenter/SSAW57_8.5.5/com.ibm.websphere.nd.doc/ae/twbs_jaxrs_multipart_formdata_from_html.html)

So go read that, I'm done :-)

... well, ok, I'll summarize and note a few things, while I'm here.

### Generic JAX-RS approach

I generally prefer to stick to the specs, not using any server-specific or implementation-specific code. WebSphere supports this by simply annotating a [java.io.File](http://docs.oracle.com/javase/7/docs/api/java/io/File.html) parameter with  [@FormParam](https://jsr311.java.net/nonav/releases/1.1/javax/ws/rs/FormParam.html). Like everything else I've tried in JAX-RS, it's elegantly simple. (I admit I'm assuming this construct is universally supported by JEE servers, but I don't know that for certain.)

Something like:
```java
    @POST  
    @Consumes(MediaType.MULTIPART_FORM_DATA)  
    public Response submitRequestFile(@FormParam("batchFile") File batchFile)
```
With WebSphere, this uploads the file to a temporary location, and gives it a generated file name. (On my Windows development system, the location seems to be my Windows %TEMP% directory.)

However, I'd prefer to prescriptively set the upload directory (so I don't have to later copy it to a more "permanent" location), and I really want the original file's name (among other things, so I can detect when the same file is inadvertently submitted again).

Because of these requirements, I needed to look for another approach.

### WebSphere-specific (Apache Wink) approach

It turns out the last example on [that WebSphere Knowledge Center page](https://www-01.ibm.com/support/knowledgecenter/SSAW57_8.5.5/com.ibm.websphere.nd.doc/ae/twbs_jaxrs_multipart_formdata_from_html.html) is what I needed. WebSphere's JAX-RS support uses [Apache Wink](https://wink.apache.org/) under the covers (although I'm not sure which Wink version goes with which WebSphere version). Regrettably, this approach is dependent on specific Apache Wink classes. But I really need this capability in order to give the desired user experience, so I'll have to live with the platform-dependence. (Unsurprisingly, both the WebSphere 8.5.5 full and Liberty Profiles seem to work fine with it.)

This approach looks more like this, using [InMultiPart](https://wink.apache.org/1.4.0/api/org/apache/wink/common/model/multipart/InMultiPart.html):
```java
    @POST  
    @Consumes(MediaType.MULTIPART_FORM_DATA)  
    public Response submitRequestFile(InMultiPart inMp)
```	

And involves looping through the parts and parsing the HTTP Headers to get the [Content-Disposition header](http://www.w3.org/TR/html401/interact/forms.html#didx-multipartform-data) needed to obtain the original file name.

In addition to the above WebSphere link, also see [Apache Wink : 7.8 MultiPart](http://wink.apache.org/1.0/html/7.8%20MultiPart.html).

## Gotchas

I'll note a few problematic behaviors we discovered during the implementation and testing.

### Internet Explorer and file input elements

Apparently [Internet Explorer has a security setting where it can provide full local file paths in the Content-Disposition header](https://msdn.microsoft.com/en-us/library/ms535128%28v=vs.85%29.aspx). The setting can be different depending on which "[Zone](https://msdn.microsoft.com/en-us/library/ms537183%28v=vs.85%29.aspx)" the site you're visiting is in, but apparently in our partner's IE, he had the setting enabled for our site. I expect he had added us to his Trusted Sites list.

Further, the [javax.mail.internet.ContentDisposition](https://docs.oracle.com/javaee/6/api/javax/mail/internet/ContentDisposition.html) class I was initially using to parse this header turned out to have the behavior of losing the backslashes in the Windows path. [According to its documentation, this is a bug in IE's encoding of the slashes](https://docs.oracle.com/javaee/6/api/javax/mail/internet/package-summary.html). There is a workaround by setting a Java System property, `mail.mime.windowsfilenames`, although I didn't prefer to affect the whole JVM. (Instead I implemented a regular-expression parse of the header, which I'm sure does not cover every case. I both love and hate regular expressions, but that's a different topic.)

Granted, this service won't normally be called from a browser and HTML page, but during testing, it sometimes is. And even there, using a different browser is acceptable. But still, if it wasn't too much work, I'd prefer to handle this more robustly "just in case".

### .NET client error on the GET request

Our partner appears to be using a C# .NET client, and even after he had success submitting a file to our POST URL, he was getting this error upon calling our GET URL from [HttpWebRequest](https://msdn.microsoft.com/en-us/library/system.net.httpwebrequest%28v=vs.110%29.aspx).[GetResponse()](https://msdn.microsoft.com/en-us/library/system.net.httpwebrequest.getresponse%28v=vs.110%29.aspx):

“The server committed a protocol violation. Section=ResponseStatusLine”

[Apparently this is a fairly common problem](https://www.google.com/search?q=the+server+committed+a+protocol+violation.+section%3Dresponsestatusline&ie=utf-8&oe=utf-8), and thankfully, one of the simplest [suggested resolutions](http://stackoverflow.com/questions/2482715/the-server-committed-a-protocol-violation-section-responsestatusline-error) to this, setting `KeepAlive` to `false`, resolved it.
