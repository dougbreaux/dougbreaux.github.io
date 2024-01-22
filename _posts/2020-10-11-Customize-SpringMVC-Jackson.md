---
title: Customizing SpringMVC Jackson Behaviors
tags:
  - spring
  - springmvc
  - jackson
  - json
published: true
---
These days it seems almost all examples of doing anything with Spring assume Spring Boot, which we're not using. So here's my foray into modifying the Jackson `ObjectMapper` that SpringMVC configures and customizes by default.

Namely, I wanted to revert to the Jackson default of throwing an error on any incoming JSON requests to my API that have fields I don't recognize. For some reason, [Spring MVC changes this default](https://docs.spring.io/spring-framework/docs/4.3.x/spring-framework-reference/html/mvc.html#mvc-config-enable).

After some Stack Overflow searches (again, almost entirely addressing how to do this with Spring Boot), and fiddling with some code in a debugger, I eventually figured out the simple solution of:
1. Replacing my XML `<mvc:annotation-driven/>` with annotation `@EnableWebMvc` on an `@Configuration` class
2. Adding the following code to that class:
```java
/**
 * To override any SpringMVC defaults
 */
@EnableWebMvc
@Configuration
public class CustomWebConfiguration implements WebMvcConfigurer {

    @Override
    public void extendMessageConverters(List<HttpMessageConverter<?>> converters) {

        for (HttpMessageConverter<?> converter : converters) {
            if (converter instanceof MappingJackson2HttpMessageConverter) {
                ((MappingJackson2HttpMessageConverter) converter).getObjectMapper().
                    enable(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES);
                break;
            }
        }
    }
}
```

I had no success trying to get the `ObjectMapper` instance and calling its `enable()` method from XML, and apparently you can't mix and match the XML `<mvc:annotation-driven/>` with this Java Configuration object. But fortunately I was already doing the rest of my MVC Spring setup via annotations, using only `<context:component-scan />` to kick it off.

(Yet another topic, we use XML configuration for the vast majority of our code, for a few reasons. First, historical and existing shared code. Second, I _like_ having all the configuration in just few places rather than spread out all over the code. Third, I try to keep Spring-specific references out of any code that doesn't already depend on Spring. Thus, we _do_ use Spring annotations in our Controller classes, which are, by definition, dependent on Spring MVC.)

## Relevant References
* [My own question and answers on Stack Overflow](https://stackoverflow.com/q/64286641/796761)
* [how do I throw a error on unknown fields in json request to spring restapi](https://stackoverflow.com/q/43120292/796761)
* [Spring Boot 1.4 Customize Internal Jackson Deserialization](https://stackoverflow.com/q/42874369/796761)
* [How do I obtain the Jackson ObjectMapper in use by Spring 4.1?](https://stackoverflow.com/q/30060006/796761)
* [Official Spring Boot documentation](https://docs.spring.io/spring-boot/docs/current/reference/htmlsingle/#howto-customize-the-jackson-objectmapper)
