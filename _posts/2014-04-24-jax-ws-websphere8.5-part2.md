---
title: JAX-WS Code for WebSphere 8.5, Part 2
tags: [	rad ,wsimport, jax-ws ]
---
As a follow-up to [Part 1](/2014/03/13/jax-ws-websphere8.5.html), here are some additional considerations for generating JAX-WS code.

## wsdlLocation

The `wsdlLocation` property for wsimport (whether from the command-line or from Ant) is placed in the generated JAX-WS @WebServiceClient class. It's placed both in that class annotation and in the static initializer block.

If you do not specify this option, the generated code will reference the absolute "**file:**" path to the .wsdl file on the local machine, which obviously won't work when deployed anywhere else. Alternative ways to deal with this are:

1.  Use an Ant <replace> task to search and replace the generated code with something that does work. This was an approach we used in the past but is no longer necessary.
2.  Set wsdlLocation to a relative or absolute path-only value, in which case the generated code will look for the .wsdl file on the application's classpath. Thus, the file will have to be stored/copied/deployed into a directory in the classpath. (And note that WEB-INF is not on the classpath, so where we had been storing our wsdl files, /WEB-INF/wsdl/file.wsdl would not be found.)
3.  **Set wsdlLocation to a full file:/// URL that starts at the root of the WAR file. That is, "file:///WEB-INF/wsdl/file.wsdl"** (note the 3 slashes after file:)**.** To my surprise, this works. _I'm looking for a reference to officially document that URL("file:///...") from within a JEE Web Application will look at the root of the WAR._
4.  Don't use the client class' default constructor, but rather use the one that accepts a URL containing the deployed .wsdl file's location.

Option **3** seems to me the cleanest and simplest with our current projects' directory conventions, so this is what I plan to use. For example:

`wsdlLocation="file:///WEB-INF/wsdl/sampleService.wsdl"`

## Client vs. Server

wsimport will generate:

1.  A Java interface describing the Web Service, annotated with @WebService. This interface will take the name of the `<wsdl:portType>` element from the WSDL
2.  A client proxy class that extends `javax.xml.ws.Service`, annotated with @WebServiceClient. This class will take the name of the `<wsdl:service>` element from the WSDL. _Contrary to what you might expect from the base class name, this is indeed a client proxy, not a service._
3.  JAXB (Java XML binding) classes representing the WSDL and XML Schema elements and types defined in the WSDL file

Of these, item **2** is not necessary for a JAX-WS _service_. In fact, the existence of a client class could be confusing.

An alternative to using wsimport for the service code is to generate it with RAD tooling, which if you specify that you're creating a service, will not create the client class. This will also create a "stub" service implementation class, which wsimport does not do.

The generated service implementation class will be annotated with @WebService with name and targetNamespace attributes that match those of the generated interface described in item **1**. Additional attributes for the serviceName and portName will be added as well (matching the `<wsdl:service>` and `<wsdl:binding>` elements, respectively).

_Strangely (to my thinking) this generated class does not actually implement the Java interface._

However, relying on RAD tooling rather than scripting may be considered to reduce the repeatability of future builds, so it might be preferable to use the wsimport approach, delete the generated client proxy, and manually create the @WebService class with the proper annotation attributes and proper methods.

In either case, the @WebService implementation class will have actual calls to business code manually added to it, so once it's generated it should not be overwritten by any future process. Thus, perhaps the better approach is to initially create the service with RAD tooling, then subsequently use wsimport if WSDL changes require code to be regenerated.

## Generated Code and Source Control

An earlier convention on our project was to generate the JAX-WS client code as part of the normal build process, every time the application is built. This is a reasonable, "ideal" approach since none of this code is "source" in the conventional sense. That is, it doesn't need to be tracked for human edits or backed up for recovery purposes.

However, since theoretically behaviors could change with newer code generations, it does seem safer to version-control this code. This would also allow easy recovery of previous versions of generated code if that became necessary.

Doing so would also

*   reduce build times (although perhaps not significantly)
*   ensure that new developers immediately have a fully compilable set of source code for a project.

Finally, even with version-controlled generated code, having scripted methods to generate the code is still useful. This ensures that code generation options are documented and repeatable. Thus, we will be creating Ant targets even if they're not used as part of the default target and automated build process.
