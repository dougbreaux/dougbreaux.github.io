---
title: Find long-running IHS (web) requests
tags: [	httpd, ihs, apache, tuning, logging, grep ]
---
Quick way to locate or watch for long-running IHS requests:

### Logging response times

Enable [microsecond response time logging with the %D LogFormat option](http://httpd.apache.org/docs/2.2/mod/mod_log_config.html). For example:

`LogFormat "%h %l %u %t \"%r\" %>s %b %D" common`

### Finding Responses longer than 1 second

Then, if you put it at the end of the line like that, the following egrep pattern could filter out, say, those items that take longer than 1 second:

`egrep "[0-9]{7}$" access_log`

Where 7 digits means you've gotten past 999,999 microseconds.

If you don't want it at the end of the line, you could add some fixed delimiters to locate it in the log string in another manner.

### Actively watching for long-running responses

Or to actively watch for such requests (assuming you have command-line tail on your platform):

`tail -f access_log | egrep "[0-9]{7}$"`
