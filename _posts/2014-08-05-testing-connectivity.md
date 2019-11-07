---
title: Testing Remote TCP/IP Connectivity
tags: [ firewall, tcip/ip, linux, network, ip, ssh, port, telnet, openssl, rhel ]
---
We frequently need to confirm connectivity between systems on particular ports.

* TOC
{:toc}

# telnet

The simplest way to do this is with the telnet command. The syntax is:

`telnet <server> <port>`

### Failure

One kind of failure looks like this:
```
telnet <server> <port>  
Trying...  
telnet: connect: Connection refused
```
This typically means that the connection reached the destination server, but nothing was listening on that port. It's also possible that it means some firewall between the two systems is flat-out rejecting the request.

Another like this:
```
telnet <server> <port>  
Trying...
```
_... after a notable delay, eventually you'll get ..._

`telnet: connect: Connection timed out`

This means a firewall isn't letting the connection through, or possibly that the remote system isn't routing correctly back to the originating system

### Success

And success looks like this:
```
telnet <server> <port>  
Trying...  
Connected to <server>  
Escape character is '^]'.
```
On any system that has telnet installed, this seems to be the simplest approach.

# ssh

Some Linuxes, including at least RHEL, apparently do not have telnet installed by default. Presumably because it's insecure if you login with it. Regrettably, that means you can't perform the above connectivity test with it, which is not itself insecure.

If you're unable or not allowed to install the telnet client, the ssh command has a similar way to attempt a connection on a particular port. Regrettably, its success/failure is more unclear (to me). The syntax is

`ssh <server> -p <port>`

### Failure

One kind of failure looks like this:
```
ssh <server> -p <port>  
ssh: connect to host <server> port <port>: Connection refused
```
I believe this can happen either when a firewall is rejecting the connection or when the connected server is not listening on the requested port.

Another kind of failure looks like this:

`ssh <server> -p <port>`

... Followed by just sitting there doing nothing.

I believe this means some firewall isn't letting you through but isn't actively rejecting the connection either. We saw this when the first firewall out of our origination system was allowing us through but the second one into our destination system was not.

### Success

Regrettably, best I can tell, Success looks exactly like the second failure scenario. That is,

`ssh <server> -p <port>`

... Followed by just sitting there doing nothing.

You're connected and can type (appropriate) commands to the connected system, but there's no indication that you're connected.

Thus, I really don't like using ssh to test connectivity. It can prove immediate problems via the first kind of failure, but when that doesn't occur doesn't give me confidence that the connection truly worked.

# openssl

This seems a better alternative to ssh, but is more cryptic to remember. Its syntax is:

`openssl s_client -connect <server>:<port>`

### Failure

Either:
```
openssl s_client -connect <server>:<port>  
socket: Connection refused  
connect:errno=111
```
Or:

`openssl s_client -connect <server>:<port>`

_... after a notable delay ..._
```
connect: Connection timed out  
connect:errno=78
```
### Success

Success gives definitive feedback:
```
openssl s_client -connect <server>:<port>  
CONNECTED(00000003)  
4398003263296:error:140770FC:SSL routines:SSL23_GET_SERVER_HELLO:unknown protocol:s23_clnt.c:766:  
---  
no peer certificate available  
---  
No client certificate CA names sent  
---  
SSL handshake has read 7 bytes and written 263 bytes  
---  
New, (NONE), Cipher is (NONE)  
Secure Renegotiation IS NOT supported  
Compression: NONE  
Expansion: NONE  
---
```
