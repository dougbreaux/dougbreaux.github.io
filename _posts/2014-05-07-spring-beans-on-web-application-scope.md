---
title: Spring Beans on Web Application Scope
tags: [  jsp, scope, servletcontext, el, spring ]
---
There are times when we'd like to place injected Spring beans onto a scope where they can be accessed directly by JSTL EL expressions (`${variable}`). Perhaps URLs from JEE Resource References to be used in hrefs.

Spring has a class that enables us to do this directly from its configuration file, [ServletContextAttributeExporter](http://docs.spring.io/spring/docs/2.5.x/api/org/springframework/web/context/support/ServletContextAttributeExporter.html). This class will place beans on "Web Application Scope", also known as "Servlet Context".

It has attribute of a Map of keys to value objects, into which you can inject any Spring-defined beans you want, under any key names.

For instance, with a URL resource reference:

```xml
    <!-- JEE URL resource-reference -->  
    <jee:jndi-lookup id="staticContentUrl" jndi-name="staticContentUrl" resource-ref="true"/>

    <!-- Add specified beans directly to Web Application Scope (a.k.a. Servlet Context)  
         for global access, particularly in JSPs -->  
    <bean class="org.springframework.web.context.support.ServletContextAttributeExporter">  
        <property name="attributes">  
            <map>  
                <entry key="staticContent" value-ref="staticContentUrl"/>  
            </map>  
        </property>  
    </bean>
```    

Then you would reference these values in a JSP like this:

```jsp
<a href="${staticContent}/index.html"/>Home Page</a>
```
