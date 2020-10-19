---
published: false
title: Retrieving the Contrast Security agent jar from a script
tags:
  - agent
  - jar
  - docker
  - contrast
  - security
  - curl
  - contrast-security
---
(In preparation for pulling into a Docker image of a web application.)

## References

- [https://docs.contrastsecurity.com/tools-apiaccess.html](https://docs.contrastsecurity.com/tools-apiaccess.html)
- [https://app.contrastsecurity.com/Contrast/docs/restapi/index.html](https://app.contrastsecurity.com/Contrast/docs/restapi/index.html)


## API Keys

In order to get the appropriate API keys, you visit the **Your Account** page on the Contrast Security site.

![editor_image_3a5e8e61-60d2-4a34-83b1-70cdafa428ba.png]({{site.baseurl}}/assets/editor_image_3a5e8e61-60d2-4a34-83b1-70cdafa428ba.png)

The API request will require all 3 of **API Key**, **Organization ID**, and (Personal) **Authorization Header**.

![editor_image_af751210-2aaa-4bee-83b3-4f276ddba43b]({{site.baseurl}}/assets/editor_image_af751210-2aaa-4bee-83b3-4f276ddba43b.png)

The API URL is:

[https://app.contrastsecurity.com/Contrast/](https://app.contrastsecurity.com/Contrast/)

The curl command to pull the latest Java jar, in my case, is:

```shell
$ curl -H 'API-Key:ibm-api-key' -H 'Authorization:my-personal-authorization-header' https://app.contrastsecurity.com/Contrast/api/ng/ibm-organization-id/agents/default/JAVA?jvm=1.8 -o contrast.jar
```
Or if I turn those into environment variables, so that I can later put them safely in my Dockerfile or even share the command with someone:
```shell
$ curl -H 'API-Key:'$CONTRAST_API_KEY -H 'Authorization:'$CONTRAST_AUTH https://app.contrastsecurity.com/Contrast/api/ng/$CONTRAST_ORG/agents/default/JAVA?jvm=1.8 -o contrast.jar
```