---
title: Spring MVC, JSR 303 Validation, and WebSphere
tags: [ websphere, jsr-303, spring, jsr303, springmvc, validation ]
---
(On Traditional WebSphere (tWAS) 8.5.5, Java 8, or on WebSphere Liberty 18, currently with Feature webProfile-6.0, in order to match the tWAS spec levels as closely as possible.)

## Background

We're using Spring (4.x) MVC Controllers in several of our applications, for [various](https://zeroturnaround.com/webframeworksindex/) reasons. I've found myself wanting to add basic JSR-303 validations to some of the submitted parameters or objects, and [earlier](https://www.ibm.com/developerworks/community/forums/html/threadTopic?id=ee47f46e-c56c-44e9-81be-0f94d4d3f1c5&ps=25) had [failed](https://stackoverflow.com/questions/45819588/jsr-303-validation-with-spring-mvc-on-websphere) to get this working under WebSphere.

At that time, the need wasn't that great, so I just manually validated the single parameter and moved on.

* TOC
{:toc}

But then I hit a case where I wanted to to more sophisticated validation (of REST-style web service controllers), and this would be an easier pattern than the alternatives I was aware of. So I decided to jump in again. After a bit more wrestling, I was starting to think nobody else had done this before, and I was going to have to give up, when I came across a clue that eventually led to success. So I wanted to document that, both for my own future reference, and for anyone else trying to do the same thing.

## Context

[Spring Validation](https://docs.spring.io/spring/docs/4.3.x/spring-framework-reference/html/validation.html#validation-beanvalidation) supports [JSR 303 Validation](http://beanvalidation.org/1.0/spec/). Using this would allow us to annotate beans with generic <span style="font-family:courier new,courier,monospace;">javax.validation</span> annotations, not having to tie them specifically to Spring, which is a plus particularly for any classes that aren't already tied to Spring. POJOs, etc., as opposed to the Controller classes themselves.

## Enablement

The first step is to [configure Spring to instantiate a `MethodValidationPostProcessor`](https://docs.spring.io/spring/docs/4.3.x/spring-framework-reference/html/validation.html#validation-beanvalidation-spring-method). Theoretically, the following is sufficient (for our XML-based configuration):
```xml
    <bean class="org.springframework.validation.beanvalidation.MethodValidationPostProcessor"/>
```
According to [the Spring Javadocs](https://docs.spring.io/spring/docs/4.3.16.RELEASE/javadoc-api/org/springframework/validation/beanvalidation/MethodValidationPostProcessor.html),

> The actual provider will be autodetected and automatically adapted.

And according to [the WebSphere 8.5.5 documentation](https://www.ibm.com/support/knowledgecenter/en/SSAW57_8.5.5/com.ibm.websphere.nd.multiplatform.doc/ae/cdat_beanval.html), it has such a provider. Should be good to go. Could it be this easy?

### The problem

However, enabling this under WebSphere, where our application has only the Spring-core jars, produced the following error:
```
[8/9/17 10:33:40:588 CDT] 000000a7 ServletWrappe E com.ibm.ws.webcontainer.servlet.ServletWrapper service SRVE0014E: Uncaught service() exception root cause Spring MVC Dispatcher: org.springframework.web.util.NestedServletException: Handler dispatch failed; nested exception is java.lang.NoClassDefFoundError: org.hibernate.validator.method.MethodConstraintViolationException  
...  
Caused by: java.lang.NoClassDefFoundError: org.hibernate.validator.method.MethodConstraintViolationException  
        at org.springframework.validation.beanvalidation.MethodValidationInterceptor.invoke(MethodValidationInterceptor.java:152)
```

Hibernate, eh? I don't have Hibernate, and I don't want to use Hibernate. I want to use what WebSphere already has.

### The solution

I was about on the verge of giving up when web searches caused me to dig deeper into the above Spring and WebSphere Bean Validation documentation and notice that

1.  [You can inject a different `ValidationFactory`](https://docs.spring.io/spring/docs/4.3.x/spring-framework-reference/html/validation.html#validation-beanvalidation-spring) into the Spring `MethodValidationPostProcessor`
2.  WebSphere defines JNDI objects for its ValidationFactory (and Validator) instances. (See section [Validation APIs](https://www.ibm.com/support/knowledgecenter/en/SSAW57_8.5.5/com.ibm.websphere.nd.multiplatform.doc/ae/cdat_beanval.html), no anchor to link to.)

Combining those, gets us:
```xml
    <jee:jndi-lookup id="validatorFactory" jndi-name="java:comp/ValidatorFactory" resource-ref="false"/>

    <bean class="org.springframework.validation.beanvalidation.MethodValidationPostProcessor">  
        <property name="validatorFactory" ref="validatorFactory"/>  
    </bean>
```
Voila! No more `NoClassDefFoundError`.

_Caveat: Maybe there's a better way to do this. Readers, feel free to point me there._

#### Side Note

Incidentally, when I use [this simple JSP]({% post_url 2011-05-24-jndi-lookup-tester %}) to see what the actual WebSphere-provided ValidatorFactory is, the result is `org.apache.bval.jsr303.ApacheValidatorFactory`.

Now, to _use_ the validation and ensure it actually works.

## Usage

I'm going to validate entire "model" objects being passed into my Spring MVC Controllers. So I have to do two things:

1.  Add JSR 303 field level annotations to the Model POJO fields
2.  Tell the Controllers to apply JSR 303 validations to their inputs

[WebSphere supports](https://www.ibm.com/support/knowledgecenter/en/SSAW57_8.5.5/com.ibm.websphere.nd.multiplatform.doc/ae/rdat_beanvalconstraints.html) the JSR 303 [Built-in Constraint definitions](http://beanvalidation.org/1.0/spec/#d0e5601), so we can use any of those or create our own.

Here's an excerpt from an annotated model POJO, showing multiple annotation types, both with and without custom error messages:
```java
public class TransactionRequest {  
    @NotNull(message="Business Unit is required")
    private String businessUnit;  

    @NotNull
    @Size(min=1,max=30,message="Application ID must be between 1 and 30 characters")
    private String applicationId;  

    ... getters/setters, etc.

}
``` 

And here's an excerpt from a Controller request-handling method that enables those validations of the incoming request:

```java
@Controller  
public class TransactionController {

    @PostMapping(path = "PostTransaction",  
                 consumes = { MediaType.APPLICATION_JSON_VALUE },  
                 produces = { MediaType.APPLICATION_JSON_VALUE })  
    public ResponseEntity<Object> postTransaction(  
        @Valid @RequestBody TransactionRequest tRequest) {  
            ...  
        }

    ...
}
```
Where `@Controller`, `@PostMapping`, and `@RequestBody` annotations are from Spring MVC, but @Valid is the JSR 303 generic `javax.validation.Valid`.

## Result

Now, if I call that _/PostTransaction_ URL and provide a JSON request that violates any of those validations - for example is missing the `businessUnit` - Spring MVC will automatically return an HTTP 400 error.

### Improvement Possible

Regrettably, the default 400 error is a generic 400, with `Content-Type text/html`, with a [WebSphere-specific error code](https://www.ibm.com/support/knowledgecenter/en/SSAW57_8.5.5/com.ibm.websphere.messages.doc/com.ibm.ws.webcontainer.resources.Messages.html) in it, and with no information on which validation(s) failed:
```
HTTP/1.1 400 Bad Request  
Content-Type: text/html;charset=ISO-8859-1  
...  
Error 400: SRVE0295E: Error reported: 400
````
So [in my next post, I describe a Spring MVC way to improve on that]({% post_url 2018-05-23-springmvc-jsr303-validation-customization %}).
