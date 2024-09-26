---
tags:
  - websphere
  - liberty
  - openliberty
  - java
  - spring
  - tls
  - ssl
title: Outbound TLS/SSL Connections in WebSphere / Open Liberty
---
Notes on configuring Liberty to use specific SSL/TLS configurations for outbound connections.

## Dynamic Outbound SSL Configuration

I honestly expected configuring the required `server.xml` elements to "just work" with all TLS connections, but it did not. Thus, [the StackOverflow question I posted](https://stackoverflow.com/q/78742044/796761). It turns out that for JAX-WS and JAX-RS, this is intended to be sufficient. But not for the lower-level `java.net.http.HttpClient` that I'm using.

(Note in the examples below that our use case for this is presenting the [Apple Pay merchant identity certificate](https://developer.apple.com/documentation/apple_pay_on_the_web/configuring_your_environment#3179108) in the mTLS required for [Apple Pay merchant validation](https://developer.apple.com/documentation/apple_pay_on_the_web/apple_pay_js_api/providing_merchant_validation).)

### server.xml

Of course this assumes a feature that enables SSL/TLS, the current being `transportSecurity-1.0` (which is pulled in by higher-level features as well).

Then add elements to define the keystore and the configuration that uses it for specific host(s):
```xml
    <keyStore id="applePayKeyStore" location="/keys/MerchID.p12" password="${APPLE_KEYSTORE_PASSWORD}" readOnly="true"/>
    <ssl id="applePaySSL" keyStoreRef="applePayKeyStore" clientAuthentication="true" sslProtocol="TLSv1.2" trustDefaultCerts="true">
        <outboundConnection host="${APPLE_VALIDATION_HOST}"/>
    </ssl>
```

### Java code

Excerpt:

```java
        HttpRequest request = HttpRequest.newBuilder().uri(validationEndpoint)
            .header("Content-Type", "application/json")
            .POST(BodyPublishers.ofString(jsonRequest))
            .build();

        HttpClient client = HttpClient.newBuilder()
            .sslContext(sslContext).build();

        String responseData = client.send(request, BodyHandlers.ofString()).body();
```

Where:
* `validationEndpoint` is the injected URL on server `${APPLE_VALIDATION_HOST}`: 
* `sslContext` is also injected, as I'll show below

Alternatively, the first cut at this for the `SSLContext` was explicitly using the Liberty-specific [JSSEHelper](https://openliberty.io/docs/modules/reference/24.0.0.8/com.ibm.websphere.appserver.api.ssl_1.6-javadoc/com/ibm/websphere/ssl/JSSEHelper.html) class:

```java
        SSLContext sslContext =
            JSSEHelper.getInstance().getSSLContext("applePaySSL", null, null);
```

### Injecting the `SSLContext`

We use Spring DI with mostly XML bean configuration, so here are my relevant beans that allow the Java code to not depend on the Liberty classes:

```xml
    <bean id="libertyJSSEHelper" class="com.ibm.websphere.ssl.JSSEHelper" factory-method="getInstance"/>

    <bean id="appleSSLContext" factory-bean="libertyJSSEHelper" factory-method="getSSLContext">
        <constructor-arg index="0" value="applePaySSL"/>
        <constructor-arg index="1"><null/></constructor-arg>
        <constructor-arg index="2"><null/></constructor-arg>
    </bean>
```

## References

* [WebSphere Liberty Configuring SSL Settings for outbound communications](https://www.ibm.com/docs/en/was-liberty/base?topic=liberty-configuring-ssl-settings-outbound-communications)
* [Open Liberty Configure outbound TLS](https://openliberty.io/docs/latest/reference/feature/transportSecurity-1.0.html#outbound)
* [Open Liberty ssl server configuration elements](https://openliberty.io/docs/latest/reference/config/ssl.html)
* [My StackOverflow question](https://stackoverflow.com/q/78742044/796761) that produced this post

