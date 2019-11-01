---
title: mod_mpmstats to analyze thread usage in IBM HTTP Server
tags: [ ihs, mpmstats, stats, apache, httpd ]
---
<content type="html">

(Related to my earlier [post on mod_status](https://www.ibm.com/developerworks/community/blogs/Dougclectica/entry/using_ibm_http_server_6_1_diagnostic_capabilities_with_websphere7).)

Found this useful tidbit today from [IBM HTTP Server Performance Tuning](https://publib.boulder.ibm.com/httpserv/ihsdiag/ihs_performance.html):

> For IBM HTTP Server 7.0 and later, [mod_mpmstats](https://publib.boulder.ibm.com/httpserv/ihsdiag/2.0/mod_mpmstats.html) is enabled automatically.
> 
> *   Check entries like this in the error log to determine how many simultaneous connections were in use at different times of the day:
>     
>     <pre>[Thu Aug 19 14:01:00 2004] [notice] mpmstats: rdy 712 **bsy 312** rd 121 wr 173 ka 0 log 0 dns 0 cls 18
>     [Thu Aug 19 14:02:30 2004] [notice] mpmstats: rdy 809 **bsy 215** rd 131 wr 44 ka 0 log 0 dns 0 cls 40
>     [Thu Aug 19 14:04:01 2004] [notice] mpmstats: rdy 707 **bsy 317** rd 193 wr 97 ka 0 log 0 dns 0 cls 27
>     [Thu Aug 19 14:05:32 2004] [notice] mpmstats: rdy 731 **bsy 293** rd 196 wr 39 ka 0 log 0 dns 0 cls 58
>     </pre>

This is a quick way to look at your IHS load over time.

The fields logged are described in the table below:

<table style="width: 90%;" border="1">

<tbody>

<tr>

<td>field</td>

<td>description</td>

</tr>

<tr>

<td>rdy (ready)</td>

<td>the number of web server threads started and ready to process new client connections</td>

</tr>

<tr>

<td>bsy (busy)</td>

<td>the number of web server threads already processing a client connection</td>

</tr>

<tr>

<td>rd (reading)</td>

<td>the number of busy web server threads currently reading the request from the client</td>

</tr>

<tr>

<td>wr (writing)</td>

<td>the number of busy web server threads that have read the request from the client but are either processing the request (e.g., waiting on a response from WebSphere Application Server) or are writing the response back to the client</td>

</tr>

<tr>

<td>ka (keepalive)</td>

<td>the number of busy web server threads that are not processing a request but instead are waiting to see if the client will send another request on the same connection; refer to the KeepAliveTimeout directive to decrease the amount of time that a web server thread remains in this state</td>

</tr>

<tr>

<td>log (logging)</td>

<td>the number of busy web server threads that are writing to the access log</td>

</tr>

<tr>

<td>dns (dns lookup)</td>

<td>the number of busy web server threads that are performing a dns lookup</td>

</tr>

<tr>

<td>cls (closing)</td>

<td>the number of busy web server threads that are waiting for the client to acknowledge that the entire response has been received so that the connection can be closed</td>

</tr>

</tbody>

</table>

</content>
