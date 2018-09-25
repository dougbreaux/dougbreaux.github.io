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
