---
title: Finding the WebSphere Admin Console Port
tags: [port,admin,console,websphere]
---
Maybe there's a better reference, but
[this page in the WebSphere Commerce Infocenter](http://pic.dhe.ibm.com/infocenter/wchelp/v7r0m0/topic/com.ibm.commerce.install.doc/tasks/tigfindwasport.htm)
has it:

(Shameless copy & paste for posterity and searchability.)

> # Finding the WebSphere Application Server administration port number
>
>The WebSphere Application Server administration port number is used
>when accessing the WebSphere Application Server administration
>console.
>
>**Procedure**
>
>1.  Open
>    [WC\_profiledir](http://pic.dhe.ibm.com/infocenter/wchelp/v7r0m0/topic/com.ibm.commerce.base.doc/misc/mabhelp.htm#mabhelp__WC_profiledir)/logs/AboutThisProfile.txt
>
>2.  Look
>    for lines similar to the following:
>    
>    ``` pre codeblock
>    Administrative console port: 9102
>    Administrative console secure port: 9104
>    ```
>    
>    In the preceding example, 9102 is the port for http protocol, and
>    9104 is the port for https protocol
