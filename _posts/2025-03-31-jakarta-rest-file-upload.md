---
tags:
  - websphere
  - liberty
  - openliberty
  - java
  - rest
  - multipart
  - upload
title: Jakarta RESTful Web Service file upload
---
## Jakarta RESTful Web Service file upload

Follow-up to [previous posts](/2022/09/22/websphere-liberty-jaxrs-file-upload.html), now using the standard [Jakarta RESTful Web Services approach](https://jakarta.ee/specifications/restful-ws/3.1/jakarta-restful-ws-spec-3.1.html#consuming_multipart_formdata), with type `jakarta.ws.rs.core.EntityPart`.

In fact, while [the Liberty documentation](https://openliberty.io/docs/latest/send-receive-multipart-jaxrs.html) still describes the "old" way of doing this, it explicitly says that is deprecated and links to the above content for the "new" way.

So, while there's not much to add to that official Jakarta documentation, I'll go ahead and share the equivalent code that replaces our prior, Liberty-specific versions.

### Java Resource

```java
    protected Response processSubmit(List<EntityPart> parts) throws ResponseException
    {
        File file = null;
        Map<String, String> params = new HashMap<>();

        for (EntityPart part : parts) {

            if (part == null) {
                log.warn("Empty part found");
                continue;
            }

            String partName = part.getName();
            if (partName == null) {
                log.warn("Nameless part found");
                continue;
            }

            log.debug("partName: {}, mediaType: {}", partName, part.getMediaType());

            Optional<String> fileName = part.getFileName();

            // look for filename to determine files vs. parameters
            if (fileName.isPresent()) {

                log.debug("fileName: {}", fileName);

                try {
                    file = yourCodeToMakeAFileFromInputStream(part.getContent(), fileName.get());
                }

                catch (IOException e) {
                    log.error("saveToFile: " + e.toString());
                    return Response.status(Status.INTERNAL_SERVER_ERROR).entity("Unable to save file").build();
                }
            }

            else {

                try {
                    String value = new String(part.getContent().readAllBytes(), StandardCharsets.UTF_8);
                    log.debug("part {}={}", partName, value);
                    params.put(partName, value);
                }

                catch (IOException e) {
                    String msg = "Invalid text value submitted for " + partName;
                    log.error("{}: {}", msg, e.toString());
                    return Response.status(Status.BAD_REQUEST).entity(msg).build();
                }
            }
        }

        if (file == null) {
            String msg = "No file parameter was submitted.";
            log.warn(msg);
            return Response.status(Status.BAD_REQUEST).entity(msg).build();
        }

        return yourCodeToProcessTheFileAndTextFields(file, params);
    }
```

## References

* [Jakarta RESTful Web Services approach](https://jakarta.ee/specifications/restful-ws/3.1/jakarta-restful-ws-spec-3.1.html#consuming_multipart_formdata)
* [jakarta.ws.rs.core](https://jakarta.ee/specifications/platform/10/apidocs/jakarta/ws/rs/core/package-summary) Javadoc, including [EntityPart](https://jakarta.ee/specifications/platform/10/apidocs/jakarta/ws/rs/core/entitypart) used above


