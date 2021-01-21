---
title: Editing files in Liberty Docker containers (e.g. Trace logging)
tags:
  - docker
  - websphere
  - liberty
  - tracing
published: true
---
I discovered that the default [Liberty Docker images](https://hub.docker.com/_/websphere-liberty) - currently based on Ubuntu - don't include vi or edit for editing files. Nor sudo to be able to install those programs.

Thus, if you want to exec a shell into one of those images to temporarily edit the configuration, like to enable tracing, you can't use this path to do so.

One approach is to add vi to your Dockerfile build of your image. Something like (I did this once, but later removed it, so I'm not 100% this is all there is to it):
```dockerfile
USER root  
RUN apt-get update && apt-get install -y vim  
USER 1001
```

If you don't want to add vi permanently to your images, though, or if you want to edit a file on a container from an existing image that doesn't have vi (or sudo to add it) already, [this is not a terrible way to copy/paste in some basic file contents into a new file](https://stackoverflow.com/a/45444278/796761):

> `cp /dev/stdin myfile.txt`
> 
> Terminate your input with Ctrl+D or Ctrl+Z and, viola! You have your file created with text from the stdin.

And the [Liberty Docker location](https://www.ibm.com/support/knowledgecenter/en/SSEQTP_liberty/com.ibm.websphere.wlp.doc/ae/rwlp_dirs.html) for "on-the-fly" configuration changes (which will be automatically picked up), is

`/config/configDropins/overrides`

So, for instance, this enables some HTTP [tracing](https://www.ibm.com/support/knowledgecenter/en/SSEQTP_liberty/com.ibm.websphere.wlp.doc/ae/rwlp_logging.html):

`default@ebec778e378d:/config/configDropins/overrides$ cp /dev/stdin trace.xml`

```xml
<server>  
    <logging traceSpecification="*=info: HTTPChannel=all"/>  
</server>
```

(Followed by ^D to end the file.)

_**Edit**_: duh, didn't realize how easy it is to launch a root shell, thus being able to install vi into the running container: `-u` option in `docker exec`:

```shell
docker exec -u root -it ${CONTAINERID} sh  
apt-get update  
apt-get install vim  
vi /config/server.xml
```

(Thanks to fellow IBMer Kevin Grigorenko [@kgibm](https://github.com/kgibm) )
