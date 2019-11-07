---
title: Command-line mail test through remote SMTP Server
tags: [ linux, command-line, mail, remote, smtp, mailx ]
---
Because I investigated this for a project, Linux (at least RHEL) mailx can use a remote SMTP server, thus enabling us to test whether that server allows email sending from our application.

`mailx -S smtp=<smtp-server-address> -r <from-address> -s <subject> -v <to-address> < body.txt`

Where "-S smtp <smtp-server-address>" is the crucial component (that apparently AIX mail/mailx doesn't support) allowing you to send through a remote server rather than a locally-configured server.

-v is "verbose"

body.txt is a local file that contains the body of the test message I'm sending.

The test was initially failing like this:
```
Resolving host <server-address> . . . done.  
Connecting to <server-address> . . . connected.  
220 Greetings  
>>> HELO <local-server-name>  
250 <smtp-server-name>  
>>> MAIL FROM:<from-address>  
250 2.1.0 Ok  
>>> RCPT TO:<to-address>  
554 5.7.1 <to-address>: Relay access denied  
smtp-server: 554 5.7.1 <to-address>: Relay access denied  
"/home/<user>/dead.letter" 11/337  
. . . message not sent.
```
And success (eventually) looked like this:
```
Resolving host <smtp-server-address> . . . done.  
Connecting to <smtp-server-address> . . . connected.  
220 Greetings  
>>> HELO <local-server-address>  
250 <smtp-server-name>  
>>> MAIL FROM:<from-address>  
250 2.1.0 Ok  
>>> RCPT TO:<to-address>  
250 2.1.5 Ok  
>>> DATA  
354 End data with <CR><LF>.<CR><LF>  
>>> .  
250 2.0.0 Ok: queued as 7AA5360001  
>>> QUIT  
221 2.0.0 Bye
```
