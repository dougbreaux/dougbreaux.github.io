---
title: SSH tunnels to Docker image registry, on Windows
tags: [ ssh, docker, windows ]
---
I've been working with Docker lately (for WebSphere Liberty).

More I probably will write about that later, but this brief post is about pushing a Docker image to a private local registry that I can only reach through a [2-hop SSH tunnel](https://www.ibm.com/developerworks/community/blogs/Dougclectica/entry/SSH_tips).

It turns out unlike "native" Docker on Linux, the Docker for Windows daemon that push/pull uses isn't using the same networking that the containers are. Looks like I have to get to the underlying VM, but [can't do this directly](https://blog.jongallant.com/2017/11/ssh-into-docker-vm-windows/):

> On Windows, Docker runs in a VM called MobyLinuxVM, but you cannot login to that VM via Hyper-V Manager. We aren’t technically going to SSH into the VM, we’ll create a container that has full root access and then access the file system from there.

I eventually was able to successfully follow the steps detailed in that post above, except as I need to then to ssh from the resulting container, I need Alpine + SSH. I also wanted to make my own image for the container+Docker client. Both so I knew exactly what was in it, and to see if I could get an even smaller image than that author's Ubuntu one.

So here are the two images I created for the purpose, with their source Dockerfiles on GitHub:

*   [Alpine with Docker Client](https://cloud.docker.com/u/dbreaux/repository/docker/dbreaux/alpine-with-docker-client) ([Dockerfile source](https://github.com/dougbreaux/dockerfiles/tree/master/alpine-docker-client))
*   [Alpine with SSH](https://cloud.docker.com/u/dbreaux/repository/docker/dbreaux/alpine-with-ssh) ([Dockerfile source](https://github.com/dougbreaux/dockerfiles/tree/master/alpine-ssh))

Commands to perform the process:

From Windows CMD.EXE (Might have to be as Administrator):

`C:\>docker run --privileged -it -v /var/run/docker.sock:/var/run/docker.sock dbreaux/alpine-with-docker-client`

From _that_ container:

`root@931e191d5755:/# docker run --net=host --ipc=host --uts=host --pid=host -it --security-opt=seccomp=unconfined --privileged --rm -v /:/host dbreaux/alpine-with-ssh /bin/sh`

Then run whatever SSH commands you need. I also created a private Docker image of the above alpine-with-ssh where I copied my private key file, known_hosts file for the two systems I'm going to tunnel through, and a shell script to establish my two-hop tunnel.

For quick reference, my ssh command (which is in my custom shell script) looks like:

`# ssh -o GatewayPorts=yes -o ServerAliveInterval=60 -o ProxyCommand="ssh -W %h:%p myuser@my-proxy-server" -L80:my-registry-server:80 -L443:my-registry-server:443 myuser@server-on-same-network-as-my-registry-server`

Then I can, back on my Windows workstation/host:

`docker push my-registry-server/image-name:image-tag`

### Contents of a Docker Image

Bonus tip: useful site to inspect the contents of a Docker Hub image: [https://microbadger.com/](https://microbadger.com/)

e.g. for my Alpine-with-Docker-client: [https://microbadger.com/images/dbreaux/alpine-with-docker-client](https://microbadger.com/images/dbreaux/alpine-with-docker-client)
