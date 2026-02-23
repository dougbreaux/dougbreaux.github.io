---
tags:
  - liberty
  - kubernetes
  - openshift
title: Overriding Liberty container configuration with mounted files
---
I realized I'd used this technique in a few other posts so far but hadn't directly described it. This provides a mechanism to mount either true "overrides" - like temporary patches - or more permanent external settings - like shared configuration values - into Liberty-based images at runtime.

## Overrides

Liberty `server.xml` configurations can be merged together from multiple sources, one of which is the `servers/<server-name>/configDropins/overrides` [directory](https://openliberty.io/docs/latest/reference/directory-locations-properties.html).

Thus, any valid excerpt of a `server.xml` configuration can be mounted in and override or merge with the image's immutable configuration.

For instance, temporary [log tracing](https://openliberty.io/docs/latest/log-trace-configuration.html#log_details) or shared [cors configuration](https://dougbreaux.github.io/2023/10/03/cors-with-liberty.html)

## Volume Mounts

Then, in your Kubernetes Deployment or [OpenLibertyApplication](https://openliberty.io/docs/latest/open-liberty-operator.html), you can mount these files into the `overrides` directory, and Liberty will apply whatever elements they've defined.

```yaml
  volumes:
    - name: cors-config
      configMap:
        name: liberty-cors-config
  volumeMounts:
    - mountPath: /config/configDropins/overrides/server-cors.xml
      name: cors-config
      readOnly: true
      subPath: server-cors.xml
```
