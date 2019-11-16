---
title: Spring MVC Controller, WebSphere Traditional, JSON
tags: [  json, springmvc, jackson, rest, spring, websphere ]
---
Just a quick note on doing JSON with Spring MVC, under WebSphere 8.5.5 Traditional.

This version of WebSphere includes Jackson 1.6.2 under the covers, for JSON serialization. (Apparently in WebSphere Liberty, the included Jackson isn't available for applications to directly use, but it is in WebSphere Traditional. On Liberty, you have to deploy your own copy of Jackson anyway.)

Spring 4.x "consumes" and "produces" attributes can auto serialize JSON, but apparently only if Jackson 2.x is in the classpath.

Without that, my attempts to send JSON requests resulted in, "415 Unsupported Media Type".

However, because Jackson 1.x and 2.x use different Java packages (org.codehaus.jackson vs. com.fasterxml.jackson), I was able to just drop Jackson 2 jars into my application (either inside the WAR or as a WAS shared library), and bingo, Spring can serialize JSON, without impacting anything else that relies on Jackson 1.x (like WebSphere's own JAX-RS support).

Quick example of such a Spring controller method, just for reference:
```java
@Controller  
@RequestMapping("QueryTransaction")  
public class QueryTransactionController {  

    @PostMapping(consumes = { MediaType.APPLICATION_XML_VALUE, MediaType.APPLICATION_JSON_VALUE },  
                 produces = { MediaType.APPLICATION_XML_VALUE, MediaType.APPLICATION_JSON_VALUE })  
    public @ResponseBody QueryTransResponse processRequest(  
           @RequestBody QueryTransRequest pmtRequest)  
        ....  
    }  
}
```

(Assuming, of course, that your request/response classes are annotated with JAXB annotations. And/or Jackson-specific annotations as well, if  you need any of those.)
