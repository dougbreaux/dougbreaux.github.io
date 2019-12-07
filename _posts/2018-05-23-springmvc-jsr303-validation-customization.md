---
title: Spring MVC and JSR 303 Validation error customization
tags: [	jsr303, springmvc, spring ]
---
Brief follow-up to [Spring MVC, JSR 303 Validation, and WebSphere]({% post_url 2018-05-23-springmvc-jsr303-websphere %}).

Wanting to improve on the default error messages. The article [Spring From the Trenches: Adding Validation to a REST API](https://www.petrikainulainen.net/programming/spring-framework/spring-from-the-trenches-adding-validation-to-a-rest-api/) was a detailed help. [Error Handling for REST with Spring](http://www.baeldung.com/exception-handling-for-rest-with-spring) also provides a succinct overview of the different approaches.

For me, adding an `@ExceptionHandler` method to an existing common base Controller class was an easy, straightforward option.
```java
    @ExceptionHandler(MethodArgumentNotValidException.class)  
    public ResponseEntity<Object> processValidationError(MethodArgumentNotValidException e) {

        List<ErrorResponse> errors = new ArrayList<>();

        for (FieldError f: e.getBindingResult().getFieldErrors()) {  
            errors.add(new ErrorResponse(400, f.getField() + ": " + f.getDefaultMessage()));  
        }

        return ResponseEntity.status(400).body(errors);  
    }
```
Where `ErrorResponse` is a POJO I defined that has `int code` and `String message` fields.

_(I'm still deciding whether to always return a `List`, whether to use the same 400 code for each error as for the overall response, etc. I think I might switch the "code" to String with the field name. Best-practice opinions and pointers welcome, but that's not the point of this post.)_

Which can generate a response like:
```json
[  
      {  
      "code": 400,  
      "message": "applicationId: Applicat<wbr>ion ID must be between 1 and 30 characters"  
   },  
      {  
      "code": 400,  
      "message": "businessUnit: Business Unit is required"  
   }  
]
```
