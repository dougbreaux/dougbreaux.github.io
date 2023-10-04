---
published: true
tags:
  - websphere
  - liberty
  - openliberty
  - cors
  - kubernetes
  - openshift
---
## WebSphere/Open Liberty CORS configuration

Follow-up to [CORS and WebSphere](/2021/01/12/cors-and-websphere.html)

With WL/OL, CORS settings can be managed entirely within `server.xml`. 

The relevant bit for that file looks something like:
```xml
<server>
    <cors domain="/"
          allowedOrigins="https://my-other-domain1.com,https://my-other-domain2.com,https://test-cors.org"
          allowedMethods="GET, POST, OPTIONS"
          allowedHeaders="origin, content-type, accept, authorization, cache-control"
          maxAge="3600" />
</server>
```

This element can either be added directly to `server.xml` or put in a separate file and included in, say, `/config/configDropins/overrides`.

### Mounting in OpenShift/Kubernetes pods

#### ConfigMap

Next, we can define a k8s `ConfigMap` that contains this file content, and mount it into the Liberty pods without changing their images. Among other things, this allows sharing of common rules across multiple apps, without having to maintain the allow list in each image.

In OpenShift, I created this with the Admin UI, but the YAML would look like this:

```yaml
kind: ConfigMap
apiVersion: v1
metadata:
  name: liberty-cors-config
immutable: false
data:
  server-cors.xml: |-
    <server>
        <cors domain="/"
              allowedOrigins="https://my-other-domain1.com,https://my-other-domain2.com,https://test-cors.org"
              allowedMethods="GET, POST, OPTIONS"
              allowedHeaders="origin, content-type, accept, authorization, cache-control"
              maxAge="3600" />
    </server>
```

#### Volume

We use the OpenLibertyOperator under OpenShift, so in our OpenLibertyApplication YAML, we mount the above `ConfigMap` file into each pod's `/config/configDropins/overrides` location like this:

```yaml
apiVersion: apps.openliberty.io/v1
kind: OpenLibertyApplication
...
  volumes:
    - name: cors-config
      configMap:
        name: liberty-cors-config
  volumeMounts:
    - mountPath: /config/configDropins/overrides/server-cors.xml
      name: cors-config
      readOnly: true
      subPath: server-cors.xml
...
```

### References

(Some repeated from earlier post.)

* [Configuring CORS for WebSphere Application Server](https://www.ibm.com/support/pages/node/6348518) - both tWAS and Liberty instructions
* [Configuring Cross Origin Resource Sharing on a Liberty server](https://www.ibm.com/docs/en/was-liberty/base?topic=liberty-configuring-cross-origin-resource-sharing-server)
* [test-cors.org](https://test-cors.org/) - for performing CORS tests. Note this domain in my example allow lists above.
* [OpenLiberty cors settings](https://openliberty.io/docs/latest/reference/config/cors.html)
* [WebSphere Liberty cors settings](https://www.ibm.com/docs/en/was-liberty/base?topic=SSEQTP_liberty/com.ibm.websphere.liberty.autogen.nd.doc/ae/rwlp_config_cors.htm)
