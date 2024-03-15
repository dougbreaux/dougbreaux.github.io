---
tags:
  - http
  - java
  - security
  - tls
title: Check HTTP(S) Connectivity in Java
---
Trivial Java code to try an HTTP connection to a URL. In particular, this can be useful to see whether your Java environment and its SSL/TLS configuration will successfully connect to an https URL.

### Java class

See [TestHttp](https://github.com/dougbreaux/Java-Web-Tools/blob/master/src/main/java/TestHttp.java).

Run it like:
```console
java -Djavax.net.ssl.trustStore=/config/trust.jks -Djavax.net.ssl.keyStorePassword=$TRUST_PASSWORD TestHttp https://example.com
```

### JSP

JSP you can deploy or create in your Java server environment:

See [HttpTest.jsp](https://github.com/dougbreaux/Java-Web-Tools/blob/master/WebContent/HttpTest.jsp)
