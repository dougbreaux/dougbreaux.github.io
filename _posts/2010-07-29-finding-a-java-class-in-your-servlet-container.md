---
layout: post
title: View HTTP Request Headers
tags: [jsp,java,http]
---

# View HTTP Request Headers 
If you've ever wanted to know what kind of HTTP Request headers might be coming from a client or some intermediate proxy, [here's a simple JSP](https://github.com/dougbreaux/Java-Web-Tools/blob/master/WebContent/ShowHeaders.jsp) you can manually deploy to your JEE Web Application to see a list.

```jsp
<html>  
<head><title>Show HTTP Headers</title></head>  
<body>  
<h3>HTTP Headers</h3>  
<pre>  
<%  
java.util.Enumeration e = request.getHeaderNames();  
while (e.hasMoreElements())  
{  
String name = (String) e.nextElement();  
String value = (String) request.getHeader(name);  
out.println(name + ": " + value);  
}  
%>  
</pre>  
</body>  
</html>  
```
