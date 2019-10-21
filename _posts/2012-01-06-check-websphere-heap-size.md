---
title: wsadmin Script to check the JVM heap size of a WebSphere Server
tags: [script,jvm,websphere,heap,jython,wsadmin]
---
In response to [this StackOverflow question](http://stackoverflow.com/questions/8754185/how-to-lookup-heap-usage-for-websphere), here's [a simple Jython wsadmin script](https://www.ibm.com/developerworks/mydeveloperworks/files/app/person/0100002GMN/file/3a25e372-7229-479d-a9a2-2f2684b64b84) which will display the JVM min and max heap sizes for the specified Application Server.

```shell
# Usage: wsadmin -f getJvmHeap.py server  
server = AdminConfig.getid('/Server:'+sys.argv[0]+'/')  
jvm = AdminConfig.list('JavaVirtualMachine', server)  

print 'initialHeapSize: ' + AdminConfig.showAttribute(jvm, 'initialHeapSize')  
print 'maximumHeapSize: ' + AdminConfig.showAttribute(jvm, 'maximumHeapSize')
```

**Update**: the above only obtains the heap size if a custom value has been explicitly configured. From [this other post](https://www.ibm.com/developerworks/mydeveloperworks/blogs/Dougclectica/entry/miscellaneous_wsadmin35), here's a mechanism which will obtain the maximum heap size otherwise (note there doesn't appear to be an attribute to obtain the minimum heap size):

```shell
jvmName = AdminControl.completeObjectName('WebSphere:type=JVM,process=MyServerName,*')  
print AdminControl.getAttribute(jvmName,'maxMemory')
```
