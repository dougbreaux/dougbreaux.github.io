---
title: Miscellaneous wsadmin
tags: [jython,websphere,wsadmin,python]
---
While attempting to answer [a question on StackOverflow](http://stackoverflow.com/questions/12034622/list-system-properties-in-websphere-7), I experimented a little with some [wsadmin commands](http://pic.dhe.ibm.com/infocenter/wasinfo/v7r0/index.jsp?topic=%2Fcom.ibm.websphere.express.doc%2Finfo%2Fexp%2Fae%2Fwelc6topscripting.html), so I thought I'd record what I discovered. _(I work with the Jython, rather than JACL, versions of the commands mostly because I like the idea of picking up a little of a new programming language which has other uses.)_  

First, [the AdminConfig object](http://pic.dhe.ibm.com/infocenter/wasinfo/v7r0/index.jsp?topic=%2Fcom.ibm.websphere.express.doc%2Finfo%2Fexp%2Fae%2Ftxml_adminconfig1.html) allows you to manage the WebSphere configuration repository. [The AdminControl object](http://pic.dhe.ibm.com/infocenter/wasinfo/v7r0/index.jsp?topic=%2Fcom.ibm.websphere.express.doc%2Finfo%2Fexp%2Fae%2Ftxml_admincontrolobj.html) allows you to interact with the running state of your WebSphere server.

In this particular case, I wanted to discover runtime System.properties values for a running JVM, of which many are not items you configure explicitly with WebSphere. Thus, after looking at the AdminConfig object and determining that it only had visibility into what you've configured, I determined that the AdminControl object was needed.

#### AdminConfig

Still, here are some AdminConfig commands that I've used and will likely have reason to use again:

```python
server = AdminConfig.getid('/Server:MyServerName/')  
jvm = AdminConfig.list('JavaVirtualMachine',server)  
print AdminConfig.show(jvm)  
print AdminConfig.attributes('JavaVirtualMachine')
```

You can see where I previously used this approach [to create JVM Custom Properties for Application Servers](https://www.ibm.com/developerworks/mydeveloperworks/blogs/Dougclectica/entry/wasadmin_script_to_set_websphere_jvm_properties7) and [to determine the (configured) maximum heap for a particular Application Server](https://www.ibm.com/developerworks/mydeveloperworks/blogs/Dougclectica/entry/wsadmin_script_to_check_the_jvm_heap_size_of_a_websphere_server1). (I'll return to that latter case later.)

#### AdminControl

> The AdminControl scripting object is used for operational control. It communicates with MBeans that represent live objects running a WebSphere® server process.

These commands allowed me to locate and query runtime WebSphere objects:

```python
serverName = AdminControl.completeObjectName('WebSphere:type=Server,process=MyServerName,*')  
print AdminControl.getAttributes(serverName, '[cellName nodeName]')
```

Or skip straight to the JVM:

```python
jvmName = AdminControl.completeObjectName('WebSphere:type=JVM,process=MyServerName,*')  
AdminControl.invoke(jvmName,'getProperty','user.timezone')
```

Or, returning to the maximum heap case from before, now I can see the maximum heap of a JVM even if I haven't explicitly configured one. Either of these variations, invoking a getter method, or getting an attribute, does the same thing:

```python
AdminControl.invoke(jvmName,'getMaxMemory')  
AdminControl.getAttribute(jvmName,'maxMemory')
```

Finally, here's a way to see which attributes and operations are available for a particular object:

```python
print Help.attributes(jvmName)  
print Help.operations(jvmName)
```
