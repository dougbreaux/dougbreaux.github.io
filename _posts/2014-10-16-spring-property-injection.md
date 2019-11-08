---
title: Injecting System Properties into Spring beans
tags: [ spring, system, properties, java ]
---
This is an 'oldie', but I just needed it again, so I thought it worth describing.

The Spring framework has an easy way to externalize some of the properties of your bean definition files into a Java properties file, using a [PropertyPlaceholderConfigurer](http://docs.spring.io/spring-framework/docs/2.0.8/api/org/springframework/beans/factory/config/PropertyPlaceholderConfigurer.html) bean.

As I was looking to write this, I found a couple other articles with a lot of additional, useful information on the subject:

*   [http://springtips.blogspot.com/2008/09/configuring-applications-with-spring.html](http://springtips.blogspot.com/2008/09/configuring-applications-with-spring.html)
*   [http://www.baeldung.com/2012/02/06/properties-with-spring/](http://www.baeldung.com/2012/02/06/properties-with-spring/)

However, my immediate case is a simple one of using a "hardcoded" default property value with a System Property override. For that case, the Spring config looks something like this:
```xml
    <!-- Property placeholders, overridable by System.properties -->  
    <bean class="org.springframework.beans.factory.config.PropertyPlaceholderConfigurer">  
        <property name="systemPropertiesModeName" value="SYSTEM_PROPERTIES_MODE_OVERRIDE"/>  
        <property name='properties'>  
            <props>  
                <!-- Default values if not set in System.properties -->  
                <prop key="environment">test</prop>  
            </props>  
        </property>  
    </bean>
```
(I gather that as of Spring 3.1, [PropertySourcesPlaceholderConfigurer](http://docs.spring.io/spring/docs/current/javadoc-api/org/springframework/context/support/PropertySourcesPlaceholderConfigurer.html) is preferred to [PropertyPlaceholderConfigurer](http://docs.spring.io/spring/docs/current/javadoc-api/org/springframework/beans/factory/config/PropertyPlaceholderConfigurer.html), but my current customer is on older Spring for the moment.)
