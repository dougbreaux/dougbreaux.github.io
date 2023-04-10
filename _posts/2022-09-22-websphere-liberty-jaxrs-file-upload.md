---
title: WebSphere Liberty JAX-RS File Upload
tags:
  - upload
  - jax-rs
  - http
  - file
  - websphere
  - rest
  - jaxrs
  - liberty
published: true
---
Documenting the steps to accept `multipart/form-data` submission of a file over JAX-RS, in current versions of WebSphere Liberty.

(This is an update to [JAX-RS in WebSphere to accept uploaded files]({% post_url 2015-12-17-websphere-jax-rs-file-upload %}).)

## References

- [Get multipart/form-data parts with IAttachment](https://stackoverflow.com/q/68638926/796761) (StackOverflow)
- [Receive multipart/form-data parts with Jakarta Restful Web Services resources](https://openliberty.io/docs/latest/send-receive-multipart-jaxrs.html#_receive_multipartform_data_parts_with_jakarta_restful_web_services_resources) (OpenLiberty documentation)
- [Configuring a resource to receive multipart/form-data parts from an HTML form submission in JAX-RS 2.0](https://www.ibm.com/docs/en/was-liberty/base?topic=djr2al-configuring-resource-receive-multipartform-data-parts-from-html-form-submission-in-jax-rs-20) (WebSphere Liberty documentation)

## Approach

Note, first, that this is again using a Liberty-specific implementation and class. However,
1. It's not dependent on the internal, third party library Liberty uses for JAX-RS (previously Apache Wink, now Apache CXF)
1. It's using an approach that hopefully will be somewhat similar to what is now in [Jakarata Rest 3.1](https://jakarta.ee/specifications/restful-ws/3.1/) (March, 2022), not yet [available in Liberty](https://www.ibm.com/docs/en/was-liberty/base?topic=management-liberty-features), but maybe imminently?

### Maven dependency

```xml
<dependency>
    <groupId>com.ibm.websphere.appserver.api</groupId>
    <artifactId>com.ibm.websphere.appserver.api.jaxrs20</artifactId>
    <version>1.1.68</version>
    <scope>provided</scope>
</dependency>
```

### Liberty server.xml

I'm currently using feature `webProfile-8.0`, which includes the necessary subfeatures. Or see [the list of Liberty features](https://www.ibm.com/docs/en/was-liberty/base?topic=management-liberty-features) if you're being more specific.

### Java Resource

Method signature to accept `multipart/form-data` and have access to the right kinds of objects to process the uploaded file (along with other, non-file "parts"):

```java
import javax.activation.DataHandler;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import javax.ws.rs.core.Response.Status;
import com.ibm.websphere.jaxrs20.multipart.IAttachment
...
@POST
@Consumes(MediaType.MULTIPART_FORM_DATA)
public Response submitFile(
    List<IAttachment> attachments) throws IOException
```

Note that we're submitting both text-field values and a file, and only 1 file at a time. Thus, some of the simple logic below was sufficient.

Note also, some sample `IAttachment`s from when 2 text fields and a file are submitted:
```
contentType: text/plain, Content-Disposition: form-data; name="recordNumber"
contentType: text/plain, Content-Disposition: form-data; name="plateNumber"
contentType: application/pdf, Content-Disposition: form-data; name="document"; filename="file.pdf"
```
```java
{
...
    File file = null;
    Map<String, String> params = new HashMap<>();

    for (IAttachment attachment : attachments) {

        if (attachment == null) {
            log.warn("processSubmit: Empty attachment found");
            continue;
        }

        DataHandler dataHandler = attachment.getDataHandler();

        String attachmentName = dataHandler.getName();

        if (attachmentName == null) {
            log.warn("Nameless attachment found");
            continue;
        }

        String contentDisposition = attachment.getHeader("Content-Disposition");

        log.debug("attachmentName: {}, contentType: {}, Content-Disposition: {}",
       	          attachmentName, attachment.getContentType(), contentDisposition);

        // look for "filename=" to determine files vs. parameters
        if (contentDisposition.toLowerCase().contains("filename=")) {

            try {
                ... 
                file = yourCodeToMakeAFileFromInputStream(dataHandler.getInputStream());
            }

            catch (IOException e) {
                log.error("Failed to make File from InputStream: " + e.toString());
                return Response.status(Status.INTERNAL_SERVER_ERROR).
                                entity("Unable to save file").build();
            }
        }

        else {

            try {
                String value = 
                    new String(dataHandler.getInputStream().readAllBytes(), StandardCharsets.UTF_8);
                log.debug("part {}={}", attachmentName, value);
                params.put(attachmentName, value);
            }

            catch (IOException e) {
                String msg = "Invalid text value submitted for " + attachmentName;
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
