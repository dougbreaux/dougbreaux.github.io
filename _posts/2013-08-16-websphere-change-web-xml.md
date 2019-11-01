---
title: WebSphere - Making changes to web.xml without redeploying the WAR/EAR 
tags: [ web.xml, websphere ]
---
Sometimes you want to test quick changes to single files deployed on WebSphere without having to upload a whole new EAR, WAR, or even individual file. (I wish the individual file upload process was simpler and safer.)

If you have command-line access to the server, you can edit or upload many of those files in place under their deploy location, typically something like:
```
<websphere-install-root>/profiles/AppSrv01/installedApps/<ear-name>/...
```
However, for web.xml, the copy that resides under this location does not actually make use of your changes. Instead, the copy under this location does:
```
<websphere-install-root>/profiles/AppSrv01/config/cells/<cellname>/applications/<ear-name>/deployments/<application-name>/<war-name>/WEB-INF
```
_**Update**_: it appears that in web application 3.0 web.xml files, there can be a [web_merged.xml file](http://www-01.ibm.com/support/knowledgecenter/SSEQTP_8.5.5/com.ibm.websphere.base.doc/ae/crun_app_upgrade.html) which also must be edited to make changes.

Also see this StackOverflow question: [Websphere application modify web.xml doesn't work](http://stackoverflow.com/questions/29536294/websphere-application-modify-web-xml-doesnt-work)

<span class="min-tags" role="list">Tags:  <span role="listitem">[web.xml](https://www.ibm.com/developerworks/community/blogs/Dougclectica?tags=web.xml&lang=en "web.xml")</span> <span role="listitem">[websphere](https://www.ibm.com/developerworks/community/blogs/Dougclectica?tags=websphere&lang=en "websphere")</span></span>
