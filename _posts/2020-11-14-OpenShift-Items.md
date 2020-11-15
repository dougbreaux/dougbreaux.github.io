---
published: false
title: Some OpenShift Container Platform Learnings
tags:
  - redhat
  - openshift
  - shaarli
  - ocp
  - docker
---
## Arbitrary User IDs

One of the first unexpected things I learned when trying to run an existing Docker image on OCP, is that, by default, [OCP runs containers as an unpredictable, non-root user](https://docs.openshift.com/container-platform/4.5/openshift_images/create-images.html#use-uid_create-images). 

> By default, OpenShift Container Platform runs containers using an arbitrarily assigned user ID. This provides additional security against processes escaping the container due to a container engine vulnerability and thereby achieving escalated permissions on the host node.

This causes problems either for images that expect to run as root, or potentially for ones that expect to run as a specific non-root user, [like WebSphere Liberty](https://hub.docker.com/_/websphere-liberty). 

And actually, Liberty itself didn't have a problem, but some other custom things I'd done to our Liberty - [installing Contrast Security into the image](/2019/03/24/Adding-Contrast-Security-to-Docker-Liberty.html) - did have [a problem that required the proposed ~workaround~ technique](https://support.contrastsecurity.com/hc/en-us/articles/360035744111-Java-io-IOException-seen-during-startup-Can-t-promise-read-write-on-cache-dir-).

```Dockerfile
RUN mkdir /home/default/contrast && \
    chown -R 1001:0 /home/default/contrast && \
    chgrp -R 0 /home/default/contrast && \
    chmod -R g=u /home/default/contrast
```

## Allow to Run as root Anyway

The next image I tried that hits this same problem right "out of the box" is [the one for the Shaarli bookmarking app](https://hub.docker.com/r/shaarli/shaarli). And while I have [an Issue open](https://github.com/shaarli/Shaarli/issues/1641) to try to get it able to run under OCP, thus far my attempts at the above technique have been unsuccessful.

So in the meantime, I explored how to change OCP's default and allow this container to run as root. [This reference in the older OCP 3.2 documentatio](https://docs.openshift.com/enterprise/3.2/admin_guide/manage_scc.html#enable-dockerhub-images-that-require-root)n gives the relevant commands for that version. And while I couldn't find the equivalent in the documentation for the 4.5 version we're running, a bit of extrapolation and the image did start successfully:

```bash
oc adm policy add-scc-to-user anyuid system:serviceaccount:shaarli:default
```


