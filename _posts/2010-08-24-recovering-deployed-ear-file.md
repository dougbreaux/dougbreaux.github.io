---
title: Recovering deployed EAR files
tags: [websphere,backup,deploy,restore]
---
Have you ever discovered that you no longer have the EAR file for the specific version of an Enterprise Application which is deployed on one of your systems?

It turns out WebSphere keeps a copy around that can be retrieved and re-deployed elsewhere. For the Network Deployment edition of WAS v6.1, you can find a deployed EAR file in:

```
[installDir]/profiles/[DmgrProfileName]/config/cells/[cellName]/applications/[applicationName].ear/[applicationName].ear
```

(Note the ear name twice, first as a directory, then as a file.)

### Update

* _Oct 15 2010_ BTW, I don't know if this is a fairly new capability (I've been using WAS since 3.0, if you can believe it), or if I've just missed it for a long time, but I only recently realized there's an "Export" button as well for each Enterprise Application.<br>
<br>Export produces a slightly differently sized EAR file than what is on the filesystem, and the one on the filesystem will be timestamped with the original deploy time, but it's likely that the Exported version will actually suffice for this use-case.<br>
* _May 29 2014_ BTW, these EAR files do appear to contain the WAS-specific metadata files like ibm-web-bnd.xml. Thus, not exactly the EAR file that was uploaded, and thus possibly not able to be dropped in directly into another server with a different configuration.
