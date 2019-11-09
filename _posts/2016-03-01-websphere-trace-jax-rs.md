---
title: Tracing JAX-RS client messages in WebSpher
tags: [  websphere, rest, trace, wink, client, jax-rs ]
---
Through just a little trial-and-error, these trace strings get me the basic URL and request/response message contents when running [JAX-RS client code from within WebSphere Application Server 8.5](http://www-01.ibm.com/support/knowledgecenter/SSAW57_8.5.5/com.ibm.websphere.nd.multiplatform.doc/ae/twbs_jaxrs_impl_client_winkrestclient.html) (which uses [Apache Wink](http://wink.apache.org/1.0/html/6.1%20Getting%20Started%20with%20Apache%20Wink%20Client.html) as its JAX-RS implementation):

`org.apache.wink.client.internal.log.*=all: org.apache.wink.client.internal.ResourceImpl=all`

`internal.log` is the request/response messages, `ResourceImpl` is the URL.

Also See [MustGather: Web Services engine and tooling problems for WebSphere Application Server](http://www-01.ibm.com/support/docview.wss?uid=swg21198363) > **Collecting Data Manually** > **Enabling Web service trace for WebSphere Application Server V8.5, 8.0, V7.0, V6.1**

(_Similar, but more detailed, post about [tracing JAX-WS messages](https://www.ibm.com/developerworks/community/blogs/Dougclectica/entry/capturing_web_service_jax_ws_messages_in_websphere)._)
