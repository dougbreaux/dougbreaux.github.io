---
title: Liberty for a Traditionalist
tags: [ liberty, traditional, eclipse, websphere, server.xml, rad ]
---
## WebSphere Liberty vs. "Traditional"

![image](https://avatars1.githubusercontent.com/u/4928521?s=200&v=4)

Liberty is the newer, lighter-weight Java EE WebSphere server. That also gets new capabilities and [specification level support](https://www.ibm.com/support/knowledgecenter/SSAW57_liberty/com.ibm.websphere.wlp.nd.multiplatform.doc/ae/rwlp_prog_model_support.html?cp=SSAW57_8.5.5) faster than "Traditional WAS" (a.k.a. "tWAS" or "Full Profile").

* TOC
{:toc}

A few links for reference:

*   #### [Traditional WebSphere or Liberty: how to choose? - WASdev](https://w3-connections.ibm.com/dogear/click?link=d5f74145-c5e4-4271-87d7-698807ea3b1a "https://developer.ibm.com/wasdev/docs/was-classic-or-was-liberty-how-to-choose/")

*   #### [Move applications to Liberty using the Migration Toolkit - WASdev](https://w3-connections.ibm.com/dogear/click?link=9fca101f-415a-4320-b12c-7a1d656ad541 "https://developer.ibm.com/wasdev/docs/move-applications-liberty-using-migration-toolkit/")

## Conversion

Having decided to at least try to get some experience with Liberty, the next step was the learning curve of how to accomplish the same things we do under tWAS. And confirm that we actually _can_ do so. These are my notes from this exercise, for one of our representative applications.

This application is a Java EE 6, Web 3.0 application with some [Apache Wink "JAX-RS" client code](https://www.ibm.com/developerworks/community/blogs/Dougclectica/entry/A_JSON_REST_client_in_WebSphere_8_5_Full_Profile) (before the JAX-RS spec included client APIs), including the dependence on a matching version of JAXB..

## server.xml

Liberty uses a single file, `server.xml`, to do most the WebSphere configuration that tWAS manages through many files and the admin console.

(See [Directory locations and properties](https://www.ibm.com/support/knowledgecenter/SSD28V_9.0.0/com.ibm.websphere.wlp.core.doc/ae/rwlp_dirs.html) for a list of the files Liberty uses.)

### `<featureManager>`

Enable feature groups or individual features: [https://www.ibm.com/support/knowledgecenter/SSD28V_9.0.0/com.ibm.websphere.wlp.core.doc/ae/rwlp_feat.html](https://www.ibm.com/support/knowledgecenter/SSD28V_9.0.0/com.ibm.websphere.wlp.core.doc/ae/rwlp_feat.html)

My current set of features for this application:
```xml
    <!-- Enable features -->  
    <featureManager>  
        <feature>localConnector-1.0</feature>  
        <feature>adminCenter-1.0</feature>  
        <feature>jaxrs-1.1</feature>  
        <feature>webProfile-6.0</feature>  
        <feature>jaxb-2.2</feature>  
        <feature>concurrent-1.0</feature>  
        <feature>javaMail-1.5</feature>  
    </featureManager>
```

#### JavaEE Features

For the Liberty featureManager, I started with the `javaee-7.0` feature, but that includes `jaxrs-2.0`, which is not what this app is using yet, and I discovered can't coexist with `jaxrs-1.1`. So instead I added lower level Java EE individual features:

*   `webProfile-6.0`: Servlets and JSPs at EAR version 6.0 and Web application version 3.0
*   `jaxrs-1.1`: JAX-RS plus Apache Wink client
*   `jaxb-2.2`: XML and JSON mapping (Jackson), with the older version of Jackson included in tWAS 8.5.5, which the current application code depends on as well
*   `concurrent-1.0`: for [ExecutorService for asynchronous operations](https://www.ibm.com/support/knowledgecenter/SSD28V_9.0.0/com.ibm.websphere.wlp.core.doc/ae/twlp_config_managedexecutor.html)
*   `javaMail-1.5`: for sending email

Obviously, this means that any applications I run under this particular server will only have access to those older versions of the specs. If I want an app to use newer versions, it'll either have to run in a different server, or this app will have to be upgraded to support that newer spec level too. (I have a few other apps in this same situation.)

#### Additional Features:

*   `localConnector-1.0` was there by default, maybe because I added the server from within RAD. I think it might be for deploying from RAD/Eclipse.
*   `adminCenter-1.0` is an optional feature for viewing and potentially editing the server.xml remotely. I haven't needed it, but wanted to see what it did.

### `<keystore>`

*   [Enabling SSL communication in Liberty](https://www.ibm.com/support/knowledgecenter/SSEQTP_liberty/com.ibm.websphere.wlp.doc/ae/twlp_sec_ssl.html)
*   [SSL defaults in Liberty](https://www.ibm.com/support/knowledgecenter/SSEQTP_liberty/com.ibm.websphere.wlp.doc/ae/rwlp_liberty_ssl_defaults.html)
*   [securityUtility](https://www.ibm.com/support/knowledgecenter/en/SSEQTP_liberty/com.ibm.websphere.wlp.doc/ae/rwlp_command_securityutil.html)

```xml
    <!-- This template enables security. To get the full use of all the capabilities, a keystore and user registry are required. -->

    <!-- For the keystore, default keys are generated and stored in a keystore. To provide the keystore password, generate an  
         encoded password using bin/securityUtility encode and add it below in the password attribute of the keyStore element. -->  
    <keyStore id="defaultKeyStore" password="{xor}blahblah"/>
```
xor'ed password isn't truly secure, so don't share the real file or configuration line if you care to keep the password secret. It's just mildly obscured by this format.

This file is also used, by default, as the trust store for placing the server certificates necessary to do _https_ to remote servers. What we "Retrieve from port" into the "CellDefaultTrustStore" in our tWAS. So I had to manually add the appropriate certificates to this file, using the Java keytool command.

As the link above indicates, the Liberty "defaultKeystore" is in the server's `resources/security` directory, file named `key.jks`.

`keytool -keystore "/opt/IBM/WebSphere/Liberty/usr/servers/defaultServer/resources/security/key.jks" -importcert -file site1.der -alias site1`

### `<authData>`

JAAS authentication aliases
```xml
    <!-- JAAS authentication aliases -->  
    <authData id="mydbid" password="{xor}blahblah" user="mydbuser"/>
```
Same bin/securityUtility script to get the xor'ed password to put in the file.

### `<jdbcDriver>`

To define DB2 DataSources.
```xml
    <!-- DB2 JDBC -->  
    <library id="db2jcc">  
        <fileset dir="${lib.path}/DB2" includes="db2jcc4.jar"/>  
    </library>  
    <jdbcDriver id="IBMJCCDriver" libraryRef="db2jcc"/>
```
Where the `${lib.path}` is defined in a different Liberty file, `bootstrap.properties`:
```properties
lib.path=/projects/libraries
```

This is actually a "Shared Library" in WebSphere. I took this shared-library approach somewhat unintentionally, just following an example I found somewhere. It's not the only way to accomplish this.

### `<dataSource>`
```xml
    <dataSource id="myappdatasource" jdbcDriverRef="IBMJCCDriver" jndiName="jdbc/myappdb">  
        <properties.db2.jcc databaseName="myappdb" portNumber="60000" serverName="dbserver"/>  
    </dataSource>
```

### `<managedExecutorService>`

For kicking off asynchronous requests.
```xml
    <!-- ExecutorService/WorkManager -->  
    <managedExecutorService jndiName="wm/default"/>
```

### `<mailSession>`

[Mail Session Object](https://www.ibm.com/support/knowledgecenter/en/SSAW57_liberty/com.ibm.websphere.liberty.autogen.nd.doc/ae/rwlp_config_mailSession.html) - element and attribute description in IBM Knowledge Center
```xml
    <mailSession id="myMail" jndiName="mail/myMail" mailSessionID="myMailSession" host="mymailserver.com" from="" password="" user=""/>
```

### `<jndiURLEntry>`
```xml
    <jndiURLEntry id="myUrl" jndiName="url/myEndpoint" value="https://myServer.com/myEndpointPath"/>
```

### `<logging>`

For [tracing Wink messaging](https://www.ibm.com/developerworks/community/blogs/Dougclectica/entry/Tracing_JAX_RS_client_messages_in_WebSphere).
```xml
    <logging traceSpecification="*=info: org.apache.wink.client.internal.log.*=all: org.apache.wink.client.internal.ResourceImpl=all"/>
```

### `<webApplication>`

I actually didn't add this manually, but let the RAD/Eclipse WDT tooling add it, by using the "Add and Remove" right-click menu option on the server.

However, I did manually add the <classloader> element, so that I could add "third-party" libraries to the default library types made available to the application. Again, so that I could use the Apache Wink classes. (The other 4 were there by default after adding the <span style="font-family:courier new,courier,monospace;"><classloader</span>> from the RAD/Eclipse <span style="font-family:courier new,courier,monospace;">server.xml</span> editor.)
```xml
    <webApplication contextRoot="/myapp" id="My Application" location="MyApplication.war" name="MY Application">  
        <classloader apiTypeVisibility="spec,ibm-api,api,stable,third-party"></classloader>  
    </webApplication>
```

(Thus, if I want to "remove" this app from the server, I'll do so by editing server.xml directly and commenting out that application. If I use Eclipse tooling instead, I'll lose this customization.)

## jvm.options

This Liberty file contains ... well... JVM-level options. For this app, a couple of System environment properties. e.g.:

[`-Dlog4j.logLevel=DEBUG`](https://www.ibm.com/developerworks/community/blogs/Dougclectica/entry/controlling_log4j_log_level_at_runtime)

We often set our JVM Time Zone to UTC, which I think would also be done here.
