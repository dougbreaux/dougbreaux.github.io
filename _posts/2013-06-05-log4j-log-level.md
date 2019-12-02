---
title: Controlling log4j Log Level at Runtime
tags: [java,websphere,debug,log4j]
---
# To Log or not to Log

As a general rule, DEBUG logging should not be enabled in a Production environment. It should be reserved for those things you're tracking during development and testing, or when problems occur that require more detail.

One way to address this is to have your build process produce different artifacts for different environments, but we've gone to great lengths to avoid this. (Including a simple, clever way to embed multiple environments' properties into a single properties file, and select from those at runtime. I've been trying to talk my colleague who created this into sharing a description somewhere.)

Thus, it was helpful to discover a mechanism to both provide a default value and allow it to be overridden by a runtime setting. This enables us to maintain a single file in our source control system, and produce a single build artifact to deploy to all environments, while still having different levels of logging detail in each environment.

# Variable Substitution

It turns out that log4j properties files reference System properties defined at the JVM. The syntax for such references is the familiar **${propertyName}** seen in other contexts (like JSTL EL).

Further, the log4j.properties file can itself provide a default value for that property so that nothing fails if the System property is not defined.

See [the JavaDoc for PropertyConfigurator](http://logging.apache.org/log4j/1.2/apidocs/org/apache/log4j/PropertyConfigurator.html)

> All option _values_ admit variable substitution. The syntax of variable substitution is similar to that of Unix shells. The string between an opening **"${"** and closing **"}"** is interpreted as a key. The value of the substituted variable can be defined as a system property or in the configuration file itself. The value of the key is first searched in the system properties, and if not found there, it is then searched in the configuration file being parsed. The corresponding value replaces the ${variableName} sequence. For example, if `java.home` system property is set to `/home/xyz`, then every occurrence of the sequence `${java.home}` will be interpreted as `/home/xyz`.

Thus, this becomes a useful pattern for applications to adopt:

```properties
log4j.logLevel=INFO  
# default level is INFO, can be overridden (in DEV and TEST environments) to something else  
log4j.rootLogger=${log4j.logLevel},LogFile,ErrorLog
```

# Setting the System Property

This property name doesn't have to be anything specific; it simply has to match between the properties files and the JVM property.

## Traditional WebSphere (aka tWAS)

Then in the Development and Test environments, for each JEE Server JVM, add a System property named **log4j.logLevel** and set its value to **DEBUG**.

In WebSphere Application Server (at least v6.1 - I'm not looking at a newer server at the moment), this property should be added under **WebSphere Application Servers** > **server** > **Process Definition** > **Java Virtual Machine** > **Custom Properties** > Add

It can also be added to all servers at once using [this wsadmin script]({% post_url 2011-02-18-wsadmin-jvm-properties.html %}).

## Liberty

Add to Liberty's jvm.options a line like this:

`-Dlog4j.logLevel=DEBUG`

## Notes

1.  With this configuration, changing the Application Server's JVM property will change all applications' logging levels, although only once the server is restarted. However, an individual application that wants to temporarily change its logging level can still change its own log4j properties file to hardcode a new rootLogger level instead of referencing the substitution variable property.

_Edit: updated for Liberty mechanism of setting the System property_
