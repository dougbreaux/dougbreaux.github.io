---
title: Simple Script to create URL Resources
tags: [ websphere, resources, wsadmin, url ]
--- 
This script will iterate through a list of name/URL pairs and create new Cell-level URL Resources for them.

Yes, it might be nice to have it take a command-line pair as well. And/or a command-line file that contains pairs. And support creating the Resources at levels other than the Cell.

But those will be exercises for another day for me :-)

See [createUrls.py](https://www.ibm.com/developerworks/community/files/app#/file/476eea57-13c1-4832-8860-c55efe1f53da)

Edit the list of name/url pairs in the file. Uses the default URL Provider, at the Cell level, and sets the JNDI name to "url/name".
