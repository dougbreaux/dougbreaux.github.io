---
title: MobileFirst Java SQL Adapter with Java EE DataSource
tags: [ datasource, sql, websphere, resources, java, mobilefirst, jdbc, java-ee ]
---
Minor addition to the MobileFirst Foundation [Java SQL Adapter](http://mobilefirstplatform.ibmcloud.com/tutorials/en/foundation/8.0/adapters/java-adapters/java-sql-adapter/) tutorial.

I _really_ don't want to be hardcoding Database configuration in my adapters. Or repeating it for multiple adapters that share the same Database access. (Not to mention not wanting to require the referenced Apache `BasicDataSource` class and libraries either.)

And since MobileFirst Foundation runs on a Java EE server anyway, why would I not use DataSources configured as server Resources?

(_Here's the WebSphere Liberty way to do this: [Configuring relational database connectivity in Liberty](https://www.ibm.com/support/knowledgecenter/SSEQTP_liberty/com.ibm.websphere.wlp.zseries.doc/ae/twlp_dep_configuring_ds.html)_)

So I use `javax.sql.DataSource` and a couple of `javax.naming` JNDI classes.

I'll still put the JNDI name itself in Adapter configuration parameters:
```xml
    <property name="dataSource.jndiName" displayName="DataSource JNDI Name" defaultValue="jdbc/myDataSource"/>
```

Now, in a "DAO" class that I instantiate (as a singleton) from my `Resource` class (or could do from the `Application` class), I use the following simple code to obtain that DataSource:
```java
        try {  
            javax.naming.InitialContext ctx = new javax.naming.InitialContext();  
            this.dataSource = (javax.sql.DataSource) ctx.lookup(dataSourceJndiName);  
        }  
        catch (javax.naming.NamingException e) {  
            throw new RuntimeException("Unable to locate specified DataSource: " + dataSourceJndiName);  
        }
```

Where dataSourceJndiName is obtained from the [ConfigurationAPI](https://mobilefirstplatform.ibmcloud.com/tutorials/en/foundation/8.0/adapters/java-adapters/#configuration-api):
```java
configApi.getPropertyValue("dataSource.jndiName")
```
