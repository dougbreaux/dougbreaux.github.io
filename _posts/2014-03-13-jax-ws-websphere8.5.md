---
title: JAX-WS Code for WebSphere 8.5
tags: [	wsimport, websphere, client, ant, web-services, jax-ws ]
---
## JAX-WS version

JAX-WS 2.2 is the latest version, and it's supported by WebSphere 8.5\. However, it appears to sort-of want Java 7.

[It can be used with Java 6](https://jax-ws.java.net/2.2.3/docs/jaxws-tools.html#running_on_jdk6) via the [Java Endorsed Standards Override Mechanism](http://docs.oracle.com/javase/6/docs/technotes/guides/standards/). I played with this a little and got the wsimport to work, but my Java 6 RAD/WebSphere were not working yet. [I have asked](https://www.ibm.com/developerworks/community/forums/html/topic?id=1b5409dc-4d3d-4146-aa1d-c55c025d49d7) what the "correct" way is to do this for the runtime environments, but in the meantime using JAX-WS 2.1 looks cleaner under Java 6.

## wsimport

wsimport can either be run as a script or from Ant.

The script is part of the SDK now, even included with J2SE. [The one included with WebSphere is documented in the InfoCenter](https://www.ibm.com/support/knowledgecenter/SSAW57_8.5.5/com.ibm.websphere.nd.multiplatform.doc/ae/rwbs_wsimport.html).

### Ant

The Ant task is actually provided by Sun classes, but they are included in WebSphere's jars as well. [The Wsimport Ant task is documented here](https://javaee.github.io/metro-jax-ws/doc/user-guide/ch04.html#tools-wsimport-ant-task).

#### Jar files

The jars required to run the Ant task are found in the WebSphere/AppServer/plugins directory. These two seem to be all that is required:

*   com.ibm.jaxws.tools.jar
*   com.ibm.jaxb.tools.jar

If you want to try JAX-WS 2.2\. under Java 6, you also need from the WebSphere/AppServer/endorsed_apis directory:

*   jaxb-api.jar
*   jaxws-api.jar

#### taskdef

Create an Ant taskdef like this:
```xml
    <path id="jaxws.gen.classpath">  
        <fileset dir="${websphere.plugins.dir}">  
            <include name="com.ibm.jaxws.tools.jar" />  
            <include name="com.ibm.jaxb.tools.jar" />  
        </fileset>  
    </path></span>

    <!-- Ant task definition for wsimport -->  
    <taskdef classpathref="jaxws.gen.classpath" name="wsimport" classname="com.sun.tools.ws.ant.WsImport"/></span>
```
#### wsimport task

A sample <wsimport> task looks like this:
```xml
        <wsimport sourcedestdir="${gen.src}" target="2.1"  
                  destdir="${classes.dir}"  
                  debug="true" verbose="true"  
                  wsdl="${basedir}/service.wsdl"  
                  wsdllocation="/service.wsdl"  
                  xnocompile="true"/></span>
```
*   `sourcedestdir` says to keep the generated source .java files and to put them in the specified directory. I prefer a separate source directory to distinguish it from edited code.
*   `target` is the JAX-WS version. (_It seems to default to 2.2, even with my WAS 8.5.5 Java 6 SDK._)
*   `wsdl` points to the local file to generate the proxy from
*   `wsdllocation` allows the generated code to access the necessary WSDL from a location other than where the source WSDL file was located. See [Bare JAX-WS](http://pglezen.github.io/was-config/html/jaxws.html), below, for some details. I admit I've yet to work out my preferred solution here. I want to reference it from a location like /WEB-INF/wsdl/service.wsdl, but that might still require changes to the generated source to accomplish.
*   `xnocompile` means to not compile the source code immediately. Since either RAD or a later Ant step will do this, it's unnecessary. No compiling also means the destdir isn't actually used.
*   _`xendorsed="true"` , not shown here, is necessary if you want to generate JAX-WS 2.2 code from Java 6_

## References and Articles

*   [wsimport command for JAX-WS applications](http://pic.dhe.ibm.com/infocenter/wasinfo/v8r5/topic/com.ibm.websphere.nd.multiplatform.doc/ae/rwbs_wsimport.html) (from the WebSphere InfoCenter)
*   [Wsimport Ant Task](https://jax-ws.java.net/2.2.3/docs/wsimportant.html) (official JAX-WS Reference Implementation documentation)
*   [Bare JAX-WS](http://pglezen.github.io/was-config/html/jaxws.html) (from IBMer Paul Glezen)

## _Edit_: Update for newer WebSphere fixpacks

A colleague discovered that with the latest copies of the two "plugins" jars, the wsimport task no longer works. Sure enough, <span style="font-family:courier new,courier,monospace;">com.sun.tools.ws.ant.WsImport</span> is no longer in <span style="font-family:courier new,courier,monospace;">com.ibm.jaxws.tools.jar</span>. The Knowledge Center article [Generating Java artifacts for JAX-WS applications from a WSDL file](https://www.ibm.com/support/knowledgecenter/SSEQTP_8.5.5/com.ibm.websphere.base.iseries.doc/ae/twbs_jaxwsfromwsdl.html) still claims that is the correct class for the Ant task, but we were unable to find it in any of the jars that seem to be included by the <span style="font-family:courier new,courier,monospace;">ws_ant</span> script that the article says must be used.

Instead, however, the class `com.ibm.jtc.jax.tools.ws.ant.WsImport` is in `com.ibm.jaxws.tools.jar`, and it appears to work as a drop-in replacement:
```xml
  <taskdef classpathref="jaxws.gen.classpath" name="wsimport" classname="com.ibm.jtc.jax.tools.ws.ant.WsImport"/>
 ```
