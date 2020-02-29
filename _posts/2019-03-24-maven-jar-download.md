---
title: Downloading jar files from Maven, without Maven
tags: [ curl, jars, central, opensource, public, maven, libraries ]
---
Maven Central jars can be downloaded from:

[https://repo1.maven.org/maven2/](https://repo1.maven.org/maven2/)

And easily with curl, say for Jackson Databind:

`curl -R http://repo1.maven.org/maven2/com/fasterxml/jackson/core/jackson-databind/2.9.8/jackson-databind-2.9.8.jar -o jackson-databind-2.9.8.jar`

(-R to preserve the original file timestamp)
