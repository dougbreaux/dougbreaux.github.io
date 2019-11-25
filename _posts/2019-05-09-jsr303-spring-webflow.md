---
title: JSR 303 Validation with Spring Web Flow
tags: [ spring, bean, mvc, jsr303, validation, java, webflow ]
---
A bit of additional information about using JSR-303 validation with Spring Web Flow. (See {% post_url 2018-05-23-springmvc-jsr303-websphere %}.)

I was hoping to use this instead of custom Java code with my Spring MVC/WebFlow application, but I think there are enough limitations in the simple use case (like non-deterministic validation ordering), that I'll probably stick with Java Validator code for now.

But, so that I don't lose the quick summary of it - that can doubtless be found lots of other places as well - I'm going to document it here.

Spring XML config like this:
```xml
<bean id="validator" class="org.springframework.validation.beanvalidation.LocalValidatorFactoryBean"/>

<webflow:flow-builder-services id="flowBuilderServices" validator="validator" ... />
```

Then annotations like:
```java
@Pattern(regexp = "^[\\w]{1,7}$", message="{plateNumber.pattern}")  
private String plateNumber;
```

And ValidationMessages.properties entries like:
```properties
plateNumber.pattern=Plate Number must be 1-7 alphabetic, numeric, or space characters
```

### Helpful links

*   [https://docs.spring.io/spring-webflow/docs/current/reference/html/views.html](https://docs.spring.io/spring-webflow/docs/current/reference/html/views.html)
*   [https://docs.oracle.com/javaee/6/tutorial/doc/gkahi.html](https://docs.oracle.com/javaee/6/tutorial/doc/gkahi.html)
*   [https://stackoverflow.com/a/4811273/796761](https://stackoverflow.com/a/4811273/796761)
