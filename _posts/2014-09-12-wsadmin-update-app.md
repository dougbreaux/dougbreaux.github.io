---
title: Simple Script to Update Enterprise Application
tags: [	jython, websphere, ear, script, wsadmin ]
---
I got tired of updating a dozen applications at once, across development, test, and production systems, from the WebSphere admin GUI.

So, here's a very simple wsadmin script, [updateApp.py](https://github.com/dougbreaux/websphere/blob/master/updateApp.py), based on [Update an existing Enterprise Application with a new EAR file](https://www.ibm.com/support/knowledgecenter/SSAW57_8.5.5/com.ibm.websphere.nd.multiplatform.doc/ae/txml_updatingapp.html).

Usage:

`wsadmin -f updateApp.py appName filePath [nosync]`

Where the optional "nosync" parameter tells the script not to sync out the changes after update and save. In case you want to do more than one, then sync them all at the end.  

WARNING: if you have more than one application installed, be very careful that you match the application name with the correct file.

Here's another script, [updateAppList.py](https://github.com/dougbreaux/websphere/blob/master/updateAppList.py), that I admit I haven't tested yet, that should allow you to edit a list of apps/ears to update, then update them all at once.

_UPDATE: BTW, thanks to [@ragibson](https://www.ibm.com/developerworks/community/profiles/html/profileView.do?userid=50D8K4G4CD) who made the script much more robust than it was originally_
