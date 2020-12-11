---
published: true
title: Adding Contrast Security to Docker Liberty image
tags:
  - websphere
  - security
  - docker
  - contrast
  - liberty
  - contrast-security
  - dockerfile
---
Follow-up to, and making use of [Retrieving the Contrast Security agent jar from a script]({% post_url 2019-03-22-Retrieve-Contrast-Security-jar %}).

These are the Dockerfile commands that I've successfully used to add Contrast to a Liberty image (although still some errors in the Contrast log to figure out, that don't seem to be hindering either the app or the Contrast scanning):

{% highlight Docker %}
FROM websphere-liberty:19.0.0.2-kernel

...

# Input arguments for sensitive stuff
ARG CONTRAST_API_KEY
ARG CONTRAST_ORG
ARG CONTRAST_AUTH

USER root
# Install curl to pull contrast jar. This takes a long time and a lot of data transfer
RUN apt-get update && apt-get install -y curl

# Use a contrast directory in default Liberty user's home directory
RUN mkdir /home/default/contrast && chown -R 1001:0 /home/default/contrast

# Curl retrieve latest/current contrast jar. Position of single-quotes and ARGs matter
RUN curl -H 'API-Key:'$CONTRAST_API_KEY -H 'Authorization:'$CONTRAST_AUTH https://app.contrastsecurity.com/Contrast/api/ng/$CONTRAST_ORG/agents/default/JAVA?jvm=1.8 -o /home/default/contrast/contrast.jar
USER 1001

# This was just my sanity to prove I got the jar file, not an auth error or something else
RUN ls -al /home/default/contrast
{% endhighlight %}
Note the CONTRAST_API_KEY, CONTRAST_ORG, and CONTRAST_AUTH arguments that have to be passed to the docker build command:
```Console
$ docker build --build-arg CONTRAST_API_KEY=$CONTRAST_API_KEY --build-arg CONTRAST_ORG=$CONTRAST_ORG --build-arg CONTRAST_AUTH=$CONTRAST_AUTH -t my-image-name .
```
Where I've also made those environment variables in my local shell so that they're not actually recorded in that command.
