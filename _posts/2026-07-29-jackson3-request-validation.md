---
title: Handling of Jackson 3 Parsing and Mapping Errors
tags:
  - jackson
  - json
  - spring
  - springmvc
  - validation
  - jackson3
---
## Update on JSON request validation for Jackson 3

Update to [Additional Handling of Jackson Parsing and Mapping Errors](/2020/10/11/Additional-Jackson-Parse-Errors.html) for the Jackson 3 package and class changes.

```java
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.http.converter.HttpMessageNotReadableException;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;

import tools.jackson.core.exc.StreamReadException;
import tools.jackson.databind.DatabindException;
import tools.jackson.databind.exc.MismatchedInputException; 
...
  
    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<Object> processValidationError(MethodArgumentNotValidException e) {

        ErrorList errors = new ErrorList();

        for (FieldError f: e.getBindingResult().getFieldErrors()) {
            errors.add(new ErrorResponse(f.getField(), f.getDefaultMessage()));
        }

        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(errors);
    }

    @ExceptionHandler(HttpMessageNotReadableException.class)
    public ResponseEntity<Object> handleHttpMessageNotReadable(HttpMessageNotReadableException e) {

        String msg = null;
        String code = null;
        Throwable cause = e.getCause();
        ErrorList errors = new ErrorList();

        if (cause instanceof StreamReadException) {
            StreamReadException sre = (StreamReadException) cause;
            msg = sre.getOriginalMessage();
            errors.add(new ErrorResponse(code, msg));
        }

        // special case of JsonMappingException below, too much class detail in error messages
        else if (cause instanceof MismatchedInputException) {
            MismatchedInputException mie = (MismatchedInputException) cause;
            if (mie.getPath() != null && mie.getPath().size() > 0) {
                msg = "Invalid request field: " + mie.getPath().get(0).getPropertyName();
                code = mie.getPath().get(0).getPropertyName();
                errors.add(new ErrorResponse(code, msg));
            }

            // just in case, haven't seen this condition
            else {
                msg = "Invalid request message";
                errors.add(new ErrorResponse(code, msg));
            }
        }

        else if (cause instanceof DatabindException) {
            DatabindException dbe = (DatabindException) cause;
            msg = dbe.getOriginalMessage();
            if (dbe.getPath() != null && dbe.getPath().size() > 0) {
                msg = "Invalid request field: " + dbe.getPath().get(0).getPropertyName() +
                      ": " + msg;
                code = dbe.getPath().get(0).getPropertyName();
                errors.add(new ErrorResponse(code, msg));
            }
        }

        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(errors);
    }
```
