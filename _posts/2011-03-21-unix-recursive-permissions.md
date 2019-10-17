---
title: UNIX tip - Use 'find' for recursive directory permissions
tags: [aix,find,chmod,unix]
---
When you want to make all directories executable, but not all files.

```shell
find ./ -type d -exec chmod a+x {} \;
```

[find](http://en.wikipedia.org/wiki/Find)
