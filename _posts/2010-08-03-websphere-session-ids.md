---
title: WebSphere Session IDs
tags: [session,cluster,websphere,httpsession,jsessionid,affinity,plugin]
---
![WebSphere Application Server](https://www-01.ibm.com/software/main/img/com/ws-mark-170x22.gif "WebSphere Application Server")
During investigation of some intermittent problems in one of our web applications, we observed some JSESSIONID cookie behavior that we couldn't explain, so I performed some investigation into the cookie's mechanics. I'll attempt to summarize in this article what I learned.

## JSESSIONID Cookie Format

In a clustered environment, the JSESSIONID cookie is composed of the core Session ID and a few other components. Here's an example:

<pre>JSESSIONID=0000A2MB4IJozU_VM8IffsMNfdR:v544d0o0</pre>

<table width="50%" border="1">

<thead>

<tr>

<td>Component</td>

<td>Example value</td>

</tr>

</thead>

<tbody>

<tr>

<td>Cache ID</td>

<td>0000</td>

</tr>

<tr>

<td>Session ID</td>

<td>A2MB4IJozU_VM8IffsMNfdR</td>

</tr>

<tr>

<td>Separator</td>

<td>:</td>

</tr>

<tr>

<td>Clone ID or Partition ID</td>

<td>v544d0o0</td>

</tr>

</tbody>

</table>

### Cache ID

It's still unclear to me what the different values mean here, but searching our Proxy logs indicates that the vast majority of our Sessions, the Cache ID is 0001\. For instance, a search of one day's log around 17:00 indicates the following number of cookies which contained a particular Cache ID:

<table width="50%" border="1">

<thead>

<tr>

<td>Cache ID</td>

<td>Hit count</td>

</tr>

</thead>

<tbody>

<tr>

<td>0000</td>

<td>4479</td>

</tr>

<tr>

<td>0001</td>

<td>223662</td>

</tr>

<tr>

<td>0002</td>

<td>191</td>

</tr>

</tbody>

</table>

For a particular Session ID, the Cache ID can definitely change mid-session, without any other changes. In particular, without the Clone/Partition ID changing. This does not indicate a switch to another Cluster member, but I don't know exactly what it does indicate. Based on the relative loads of our various systems, it seems possible that changing Cache IDs only occurs under heavy loads.

### Clone/Partition ID

A Partition ID is appended to the cookie if memory-to-memory replication in peer-to-peer mode is utilized for Distributed Session management. Otherwise, a Clone ID is appended.

#### Clone ID

This will match one of the CloneID attributes in the Server elements within the web server's plugin-cfg.xml file. For instance 138888kcd in:

```xml
<Server CloneID="138888kcd" ConnectTimeout="10" ExtendedHandshake="false"  
        LoadBalanceWeight="2" MaxConnections="-1" Name="server1Node01_App03"  
        ServerIOTimeout="0" WaitForContinue="false">  
...  
</Server></pre>
```

#### Partition ID

If you use memory-to-memory Session replication, your cookies will contain Partition IDs rather than Clone IDs.

Partition IDs are similar in function to Clone IDs, but best I can tell there is no direct way to determine which values correspond to which cluster members. They are internally mapped by the WebSphere HAManager to specific Clone IDs, and that mapping is exchanged with the web server plug-in so that it can maintain Session affinity and find additional cluster members for failover. (The exchange takes place in private headers on each response from WAS back to the plug-in, and those headers are removed before the response is sent back to the client.)

## Session Affinity and Failover

The Clone/Partition ID corresponds to whichever cluster member creates the Session, and the plug-in is responsible to send that Session to the same cluster member as long as it is available. From the [Scalability Redbook](http://www.redbooks.ibm.com/abstracts/sg246392.html):

> Since the Servlet 2.3 specification, as implemented by WebSphere Application Server V5.0 and higher, only a single cluster member may control/access a given Session at a time. After a Session has been created, all following requests need to go to the same application server that created the Session. This Session affinity is provided by the plug-in.

If on a subsequent request the specified cluster member is unavailable, the plug-in will choose another cluster member and attempt to connect to that. If Distributed Sessions are configured, via database persistence or memory-to-memory replication, the Session will be resumed in-progress on that new member. If not, a new Session will be created and the user's progress will be lost.

If a new cluster member is able to resume the existing Session, it will append its own Clone/Partition ID to the existing JSESSIONID cookie. For instance:

<pre>JSESSIONID=0000A2MB4IJozU_VM8IffsMNfdR:v544d0o0:v544d031</pre>

Now the plug-in knows that 2 different cluster members could potentially service this Session. If the original member becomes available again, the Session will switch back to it.

Finally, note that according to the [System Management Redbook](http://www.redbooks.ibm.com/abstracts/sg247304.html):

> WebSphere provides session affinity on a best-effort basis. There are narrow windows where session affinity fails. These windows are:
> 
> *   When a cluster member is recovering from a crash, a window exists where concurrent requests for the same session could end up in different cluster members...
> *   A server overload can cause requests belonging to the same session to go to different cluster members...

* * *

## Referenced articles and Redbooks

*   [Redbook: WebSphere Application Server V6 Scalability and Performance Handbook](http://www.redbooks.ibm.com/abstracts/sg246392.html) - The best reference; it contains most of what I've discovered thus far. Sections 6.8.1, 6.8.6, and example 6-19 in particular.
*   [Redbook: WebSphere Application Server V6.1: System Management and Configuration](http://www.redbooks.ibm.com/abstracts/sg247304.html) - Section 10.7 in particular.
*   [InfoCenter section on HTTP Session problems](http://publib.boulder.ibm.com/infocenter/wasinfo/v6r1/index.jsp?topic=/com.ibm.websphere.nd.multiplatform.doc/info/ae/ae/rtrb_httpsessprobs.html)
*   [PK83788: INCORRECT HANDLING OF PARTITION TABLES BY PLUGIN](http://www-01.ibm.com/support/docview.wss?uid=swg1PK83788)
*   [PK48101: NEWLY SPAWNED WEBSERVER PROCESSES BREAK SESSION AFFINITY WHEN MEMORY-TO-MEMORY PERSISTENCE IS CONFIGURED](http://www-01.ibm.com/support/docview.wss?rs=180&uid=swg1PK48101)
