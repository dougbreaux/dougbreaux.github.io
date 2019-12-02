---
title: wsadmin Script to set WebSphere JVM Properties
tags: [script,wsadmin,jython,property,websphere,scripting,jvm]
---
I sometimes need to set a custom JVM Property for one or more Application Servers and dislike the tedium of setting them one-at-a-time through the console.

Here's a [Jython script for wsadmin](https://github.com/dougbreaux/websphere/blob/master/addJvmProperty.py) to add a JVM Custom Property to a specified Application Server, or to "all" application servers. It will also replace an existing property with a new value and description.

Usage:

```shell
wsadmin -f addJvmProperty.py [nodeName:]<ser​verName>|all <propertyName> <propertyValue> [propertyDescription]
```

e.g.

```shell
wsadmin -f addJvmProperty.py all myProperty myValue
wsadmin -f addJvmProperty.py myNode:myServer myProperty myValue "My property description"
wsadmin -f addJvmProperty.py myServer myProperty myValue
```
