---
title: Overview of Implementing a JAX-RS Service with WebSphere Web 2.0 Feature Pack
tags: [websphere,jax-rs,rest,spring,java,wink,apache]
---

### WebSphere Configuration

1.  [Feature Pack for Web 2.0](http://www-01.ibm.com/software/webservers/appserv/was/featurepacks/web20/) installed into WebSphere. This simply copies a bunch of files, including the JAX-RS jar files, into $WAS_HOME/web2fep. The IBM JAX-RS implementation is based on [Apache Wink](http://incubator.apache.org/wink/), version 1.0 as of this writing.
2.  Created [Shared Library](http://www-01.ibm.com/support/docview.wss?uid=swg27006159#usingapp) in WAS. Applications can reference this rather than having to deploy [the jars](http://publib.boulder.ibm.com/infocenter/wasinfo/v6r1/index.jsp?topic=/com.ibm.websphere.web20fepjaxrs.doc/info/ae/ae/twbs_jaxrs_assemble.html) each time.

### Web Application Configuration

1.  [Add WebSphere REST Servlet to application's web.xml](http://publib.boulder.ibm.com/infocenter/wasinfo/v6r1/index.jsp?topic=/com.ibm.websphere.web20fepjaxrs.doc/info/ae/ae/twbs_jaxrs_configwebxml.html) 
    ```xml
    <servlet>  
        <servlet-name>JAX-RS Servlet</servlet-name>  
        <servlet-class>com.ibm.websphere.jaxrs.server.IBMRestServlet</servlet-class>  
        <init-param>
            <param-name>javax.ws.rs.Application</param-name>
            <param-value>_Java_class_name_</param-value>
        </init-param>
        <load-on-startup>1</load-on-startup>  
    </servlet>  

    <servlet-mapping>  
        <servlet-name>JAX-RS Servlet</servlet-name>  
        <url-pattern>/*</url-pattern>  
    </servlet-mapping>  
    ```
    Note that the `<init-param>` text is only required, including [creating a custom class which extends Application](http://incubator.apache.org/wink/1.0/html/JAX-RS%20Getting%20Started.html#JAX-RSGettingStarted-Step2Creatingajavax.ws.rs.core.Applicationsubclass), if we don't use the following Spring Wink support.
2.  [Integrate Wink with Spring](http://incubator.apache.org/wink/1.0/html/5.5%20Spring%20Integration.html) using a Spring-aware Wink Application subclass called [Registrar](http://incubator.apache.org/wink/1.0/api/org/apache/wink/spring/Registrar.html). This class is not part of the WebSphere Feature Pack but works fine with it. This allows you to inject your "Resource" definitions rather than hardcode them in an Application subclass.

    Perhaps more importantly, it also allows you to more easily utilize the injected interface/implementation pattern for the rest of your supporting beans.
    ```xml
    <context-param>  
        <param-name>contextConfigLocation</param-name>  
        <param-value>classpath:META-INF/server/wink-core-context.xml  
    /WEB-INF/applicationContext.xml</param-value>  
    </context-param>
    ```

    This class and its supporting classes are part of an "extensions" jar (wink-spring-support-1.0-incubating.jar) provided in the Wink distribution file available from [the Wink site](http://incubator.apache.org/wink/).

    Where META-INF/server/wink-core-context.xml is provided by the Wink Spring library and applicationContext.xml is your application's bean definitions.

3.  Configure your Resource classes in your application Spring configuration file. 
    ```xml
    <bean class="org.apache.wink.spring.Registrar">  
        <property name="instances">  
            <set>  
                <ref bean="calendarResource" />  
            </set>  
        </property>  
    </bean>  

    <bean id="calendarResource"  
          class="com.ibm.gs.calendar.service.CalendarResource">  
        <property .../>  
    </bean>
    ```

### Resource Implementation

This is the basic [annotation-based](http://jsr311.java.net/nonav/releases/1.0/javax/ws/rs/package-summary.html) JAX-RS coding. See the below "Getting Started" article, Part 1 of the "RESTful Web services" article, and the [Developing JAX-RS Web applications](http://publib.boulder.ibm.com/infocenter/wasinfo/v6r1/index.jsp?topic=/com.ibm.websphere.web20fepjaxrs.doc/info/ae/ae/container_wbs_jaxrs_goal_developing.html) section of the WebSphere Feature Pack documentation.

It's a straightforward, portable way to define the URI Paths of your Resources, the HTTP Methods supported by them, the Parameters passed to them, the Content Types supplied by them, and more.

### References

*   [Overview of IBM JAX-RS](http://publib.boulder.ibm.com/infocenter/wasinfo/v6r1/index.jsp?topic=/com.ibm.websphere.web20fepjaxrs.doc/info/ae/ae/cwbs_jaxrs_overview.html) in WebSphere InfoCenter
*   [Apache Wink : JAX-RS Getting Started](http://incubator.apache.org/wink/1.0/html/JAX-RS%20Getting%20Started.html)
*   [Apache Wink : 5.5 Spring Integration](http://incubator.apache.org/wink/1.0/html/5.5%20Spring%20Integration.html)
*   [RESTful Web services with Apache Wink, Part 1: Build an Apache Wink REST service](http://www.ibm.com/developerworks/web/library/wa-apachewink1/index.html)
*   [RESTful Web services with Apache Wink, Part 2: Advanced topics in Apache Wink REST development](http://www.ibm.com/developerworks/web/library/wa-apachewink2/index.html) (including Spring integration)
*   [Overview of JAX-RS 1.0 Features](http://wikis.sun.com/display/Jersey/Overview+of+JAX-RS+1.0+Features) (includes quick overview of most common Annotations)
