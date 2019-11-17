---
title: XML JAXB Response List of Errors
tags: [ springmvc, xml, rest, jaxb, spring ]
---
Minor addition to [Spring MVC and JSR 303 Validation error customization](https://www.ibm.com/developerworks/community/blogs/Dougclectica/entry/Spring_MVC_and_JSR_303_Validation_error_customization) and [Error pattern for REST/HTTP APIs](https://www.ibm.com/developerworks/community/blogs/Dougclectica/entry/Error_pattern_for_REST_HTTP_APIs).

### Unacceptable XML

While my earlier-mentioned API supports both JSON and XML, the XML is more legacy, and I hadn't tested all cases with it yet. Further testing revealed that my previous multi-error pattern was too simplistic for XML responses:

```java
   @ExceptionHandler(MethodArgumentNotValidException.class)  
    public ResponseEntity<Object> processValidationError(MethodArgumentNotValidException e) {

        List<ErrorResponse> errors = new ArrayList<>();

        for (FieldError f: e.getBindingResult().getFieldErrors()) {  
            errors.add(new ErrorResponse(f.getField(), f.getDefaultMessage()));  
        }

        return ResponseEntity.status(400).body(errors);  
    }
```
_(Note that's slightly different from my earlier version, I switched the ErrorResponse to use 2 Strings instead of int/String.)_

JSON was fine, but "Accept: application/xml" calls were receiving [406 Not Acceptable](https://www.w3.org/Protocols/rfc2616/rfc2616-sec10.html#sec10.4.7) when errors were returned.

### Broken Pattern?

My first thought/fear was that the above Spring `@ExceptionHandler` approach wasn't going to be smart enough to send the correct response type, based on the caller's "Accept" Request header.

But it turned out it was the much simpler issue that List isn't sufficient to have JAXB serialize out appropriate XML. I really should have remembered this from earlier JAXB endeavors.

(_Observation: Spring MVC really is powerful at figuring things out and allowing simple coding patterns._)

### XML Wrapper

The simple solution (with thanks to StackOverflow [Why my ArrayList is not marshalled with JAXB?](https://stackoverflow.com/a/4152683/796761)), is a new Errors list wrapper class, properly annotated:
```java
@XmlRootElement(name="Errors")  
public class ErrorList extends ArrayList<ErrorResponse>  
{  
    @XmlElement(name="error")  
    public List<ErrorResponse> getErrors() {  
        return this;  
    }  
}
```

With the above `@ExceptionHandler` method modified to:
```java
    @ExceptionHandler(MethodArgumentNotValidException.class)  
    public ResponseEntity<Object> processValidationError(MethodArgumentNotValidException e) {

        ErrorList errors = new ErrorList();

        for (FieldError f: e.getBindingResult().getFieldErrors()) {  
            errors.add(new ErrorResponse(f.getField(), f.getDefaultMessage()));  
        }

        return ResponseEntity.status(400).body(errors);  
    }
```

Which produces either the original JSON or the following XML:
```xml
<Errors>  
   <error>  
      <code>applicationId</code>  
      <message>may not be null</message>  
   </error>  
</Errors>
```

No more 406 HTTP response error code.
