---
tags:
  - websphere
  - liberty
  - openliberty
  - http
  - kubernetes
  - openshift
  - authentication
  - basic-authentication
  - java
  - jakartaee
  - security
title: HTTP Basic Authentication with WebSphere/Open Liberty
---
Collecting the steps to add HTTP Basic Authentication to a Liberty web application. 

In this simple case, the need to restrict access to the entire application to a tiny set of preconfigured users.

### web.xml

Add a `security-constraint` for all URLs and all users (roles):

```xml
    <security-constraint>
        <web-resource-collection>
            <web-resource-name>all</web-resource-name>
            <url-pattern>/*</url-pattern>
        </web-resource-collection>
        <auth-constraint>
            <role-name>**</role-name>
        </auth-constraint>
    </security-constraint>
```

Add a `login-config` for Basic Authentication:
```xml
    <login-config>
        <auth-method>BASIC</auth-method>
        <realm-name>My Application Realm</realm-name>
    </login-config>
```

### server.xml

References:
* [WebSphere Liberty](https://www.ibm.com/docs/en/was-liberty/core?topic=liberty-configuring-basic-user-registry)
* [OpenLiberty](https://openliberty.io/docs/latest/reference/feature/appSecurity-2.0.html#_configure_a_basic_user_registry)

Add the necessary Liberty feature(s):
```xml
    <featureManager>
        ...
        <feature>appSecurity-2.0</feature>
        <!-- most likely want TLS too -->
        <feature>transportSecurity-1.0</feature> 
        ...
    </featureManager>
```

Add a user registry:
```xml
    <basicRegistry id="basic" realm="My Application Realm">
        <user name="${USER_1}" password="${PASSWORD_1}" />
        <user name="${USER_2}" password="${PASSWORD_2}" />
    </basicRegistry>
```
(Where we'll pull these values from something external so they're not coded into the server source.)

Map the web application to the special role for "all authenticated users":
```xml
    <webApplication contextRoot="/appRoot" id="MyApp" location="MyApplication.war" name="My Application">
        <application-bnd>
            <security-role name="AllAuthenticated">
                <special-subject type="ALL_AUTHENTICATED_USERS" />
            </security-role>
        </application-bnd>
    </webApplication>
```

### Injecting the user/password values

We run our Liberty applications under OpenShift Container Platform, with the [OpenLiberty Operator](https://openliberty.io/docs/latest/open-liberty-operator.html), so we use a Kubernetes Secret to manage the logins.

From the OpenLibertyApplication YAML:
```yaml
apiVersion: apps.openliberty.io/v1
kind: OpenLibertyApplication
...
spec:
...
  envFrom:
    - secretRef:
        name: basic-auth
```

And the Secret YAML:
```yaml
kind: Secret
apiVersion: v1
metadata:
  name: basic-auth
immutable: false
type: 
stringData:
  USER_1: todouser1
  PASSWORD_1: todopassword1
  USER_2: todouser2
  PASSWORD_2: todopassword2
type: Opaque
```

Yes, this approach "hardcodes" into the image that we have 2 allowed users. You could also mount an entire "file" Secret into the Liberty `overrides` directory if you need more flexibility add or remove users without updating the container image.
