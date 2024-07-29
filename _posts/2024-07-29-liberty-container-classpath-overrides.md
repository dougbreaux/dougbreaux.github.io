---
tags:
  - websphere
  - liberty
  - openliberty
  - kubernetes
  - openshift
  - java
  - classpath
  - secret
  - configmap
title: >-
  Mounting Java classpath overrides in Liberty containers (with
  Kubernetes/OpenShift)
---
We have a use case to want to add environment-specific resource files (Java properties files, in our case) to the Java classpath of Liberty images deployed to our OpenShift clusters.

(Yes, we could instead define individual values for each property and list them separately in `ConfigMap`s/`Secret`s, but when there are many such values, a single file is easier to manage.)

## Shared Libraries

WebSphere Liberty / OpenLiberty has the notion of [shared library](https://openliberty.io/docs/latest/class-loader-library-config.html#shrdLib) definitions, and Kubernetes pods can mount `ConfigMap`s or `Secret`s as volumes.

Combining those, we can build container images with a directory defined and added to the application classpath, over which we then mount a k8s `ConfigMap`/`Secret` as a volume file to be used by the Liberty application.

## Application Configuration

### server.xml

Define a [`<library>`](https://openliberty.io/docs/latest/reference/config/library.html) element to point to a filesystem location to contain the expected file(s):

```xml
<!-- external classpath directory for injecting property file overrides -->
<library id="properties" name="properties">
    <folder dir="/class-override"/>
</library>
```
Note the dir location - `/class-override` - must match what is created in the image and what is mounted in the Secret, in the following steps.

Add a reference to this library in the [`<webApplication>`](https://openliberty.io/docs/latest/reference/config/webApplication.html) definition:

```xml
<webApplication contextRoot="/myapp" id="myApp" location="MyApp.war" name="My Application">
    <classloader commonLibraryRef="properties"/>
</webApplication>
```

### Dockerfile

Create this expected directory in the container build steps:
```docker
USER root
...
# For injecting properties files from ConfigMaps or Secrets
ARG DIR_CLASS=/class-override
RUN mkdir -p $DIR_CLASS && \
    chown -R 1001:0 $DIR_CLASS && \
    chgrp -R 0 $DIR_CLASS && \
    chmod -R g=u $DIR_CLASS
...
USER 1001
```

## Deployment

### Create the Kubernetes resources

In my case, using the OpenShift admin web UI.

The appropriate Secret(s) must be configured in each namespace (Project) that needs them. (Secrets cannot be shared across Kubernetes namespaces - a.k.a. OpenShift Projects).

A simple way to do this is to create a new **Key/value secret** and upload a properties file as its contents:

![create-secret.png]({{site.baseurl}}/assets/create-secret.png)

![create-secret2.png]({{site.baseurl}}/assets/create-secret2.png)

Then edit the file content to set the correct values for each property in the particular environment.

### Volume mounts

In whatever k8s resource manages your Liberty pods (in our case, the `OpenLibertyApplication` CRD from the [OpenLiberty Operator](https://openliberty.io/docs/latest/open-liberty-operator.html)), you'll add `volumes` and `volumeMounts` entries referencing the `ConfigMap`(s) and/or `Secret`(s) created above:

```yaml
volumes:
  - name: credentials-myApp
    secret:
      secretName: credentials-myApp
volumeMounts:
  - mountPath: /class-override/credentials.properties
    name: credentials-myApp
    subPath: credentials.properties
```