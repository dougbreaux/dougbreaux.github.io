---
title: Additional Handling of Jackson Parsing and Binding Errors
tags: [ jackson, json, spring, springmvc, validation ]
---
Brief follow-up to ({% post_url 2018-05-23-springmvc-jsr303-validation-customization %}).

In addition to the previously shown `@ExceptionHandler(MethodArgumentNotValidException.class)` method for handling JSR-303 Validation errors, we also want to handle JSON Parsing and Mapping errors by returning similarly helpful and clean JSON responses. 

Jackson apparently uses two different Exception trees for the different kinds of errors we see, `JsonParseException` and `JsonMappingException`, both of which are wrapped in `HttpMessageNotReadableException`. 

Our initial attempt was to just return the `getOriginalMessage()` string from both of those, along with the `getPath()` information when it exists. But it turns out that at least a couple of cases we want to handle produce messages with more detail than we want to reveal. (Namely, the fully-qualified class name):
1. Using a Java `enum` to limit input values to acceptable ones
2. Not accepting unknown input fields

So, combining all of the cases we see today, this appears to give useful, appropriate validation error responses:
```java
    /**
     * Common handling of JSON parsing/mapping exceptions. Care is used to not return error
     * details that would reveal internal Java package/class names.
     */
    @ExceptionHandler(HttpMessageNotReadableException.class)
    public ResponseEntity<BaseResponseMessage> processConversionException(HttpMessageNotReadableException e) {

        String msg = null;
        Throwable cause = e.getCause();

        if (cause instanceof JsonParseException) {
            JsonParseException jpe = (JsonParseException) cause;
            msg = jpe.getOriginalMessage();
        }

        // special case of JsonMappingException below, too much class detail in error messages
        else if (cause instanceof MismatchedInputException) {
            MismatchedInputException mie = (MismatchedInputException) cause;
            if (mie.getPath() != null && mie.getPath().size() > 0) {
                msg = "Invalid request field: " + mie.getPath().get(0).getFieldName();
            }

            // just in case, haven't seen this condition
            else {
                msg = "Invalid request message";
            }
        }

        else if (cause instanceof JsonMappingException) {
            JsonMappingException jme = (JsonMappingException) cause;
            msg = jme.getOriginalMessage();
            if (jme.getPath() != null && jme.getPath().size() > 0) {
                msg = "Invalid request field: " + jme.getPath().get(0).getFieldName() +
                      ": " + msg;
            }
        }

        return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                             .body(new BaseResponseMessage(CODE_ERROR_VALIDATION, msg));
    }
```

(Where our `BaseResponseMessage` is a POJO with `code` and `message` fields.)
