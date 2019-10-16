---
title: Temporarily Disabling WebSphere Cluster Members
tags: [plugin,cluster,ihs,web-server,was,webserver,failover,websphere]
---
### Background

It seems that in our current configuration the WebSphere plugin does not reliably stop sending requests to a Cluster member when it's been taken down. Or sometimes it seems to take an inordinate amount of time for it to do so, or sometimes it starts sending requests before a restarting member is fully operational.

A quick workaround is to manually edit the plugin's configuration file on each web server to comment-out the unwanted servers. The plugin will automatically detect and apply the changes within a minute or so and stop routing requests to those servers until you manually uncomment them.

### Plugin Configuration File Location

On our AIX systems, the plugin configuration file is in a location like:

/usr/IBM/HTTPServer/Plugins/config/<webservername>/plugin-cfg.xml

_(If you're ever uncertain you're looking in the correct location, look for the WebSpherePluginConfig directive in the IHS httpd.conf file.)_

### Plugin Configuration File Contents

Within that file are many configuration items, most should never be manually edited, but the ones we care about for this purpose are the <PrimaryServers> elements within each <ServerCluster> element.

The ServerCluster's "Name" attribute will tell you which element to edit.

Then the PrimaryServers element in that ServerCluster will list each of the individual <Server> Cluster members which are also defined within ServerCluster.

```xml
<ServerCluster ... Name="TestCluster" ...>  
    <Server ... Name="serverANode01_TestApp-A" ...>  
    ...  
    </Server>  
    <Server ... Name="serverBNode01_TestApp-B" ...>  
        ...  
    </Server>  
    <PrimaryServers>  
        <Server Name="serverANode01_TestApp-A"/>  
        <Server Name="serverBNode01_TestApp-B"/>  
    </PrimaryServers>  
</ServerCluster>`
```

#### Removing a specific server from Plugin dispatching

The only change we have to make is to comment-out the specific Server which we want to cease receiving requests. So to disable the TestApp-B server on serverB:

```xml
<PrimaryServers>  
    <Server Name="serverANode01_TestApp-A"/>  
    <!--Server Name="serverBNode01_TestApp-B"/-->
</PrimaryServers>
```

* * *

### Notes

1.  Don't forget to make this change on each Web Server which is configured to send requests to the Cluster.
2.  Don't forget to make this change for each relevant Cluster within the file. That is, if an entire Node is being taken down, each Cluster's PrimaryServers list must be edited.
3.  If someone knows an easier way to do this, or why stopping a server from the console doesn't automatically, immediately accomplish the same thing, please enlighten me!  
