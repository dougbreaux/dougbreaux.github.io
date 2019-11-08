---
title: 'JAXB with Java 7 and xs:boolean'
tags: [ xsd, ant, wsimport, java7, java, websphere, jax-ws, boolean, jee, jaxb ]
---
## JAXB and Boolean

It turns out that by default, JAXB 2.2, the level in Java 7, generates the wrong kinds of getters for `Boolean` (wrapper object) fields. It generates `isXXX()` getters instead of `getXXX()` getters. And according to the JavaBeans spec, only `boolean` primitives are supposed to do that.

See [https://java.net/jira/browse/JAXB-131](https://java.net/jira/browse/JAXB-131)

Among other things, Apache Commons [BeanUtils](http://commons.apache.org/proper/commons-beanutils/) [copyProperties()](http://commons.apache.org/proper/commons-beanutils/javadocs/v1.9.2/apidocs/org/apache/commons/beanutils/BeanUtils.html#copyProperties%28java.lang.Object,%20java.lang.Object%29) follows the spec and thus doesn't copy `Booleans`.

The fix is to use a JAXB compiler option, `-enableIntrospection`. See [https://jaxb.java.net/nonav/2.2.1/docs/xjc.html](https://jaxb.java.net/nonav/2.2.1/docs/xjc.html)

In the JAX-WS `<wsimport>` Ant task, it looks like this:
```xml
        <target name="wsimport">
            <wsimport sourcedestdir="${gen.src}" target="2.2"
            ...
                <xjcarg value="-enableIntrospection"/>
            </wsimport>
        </target>
```
This causes `getXXX()` methods to be generated instead of `isXXX()` methods. (I found myself thinking it would be nice if both styles of getters were produced, but I admit I don't know if that would violate some other specification or convention.)

## xs:boolean with minOccurs="0"

Related is the fact that, with this version of JAXB, XML schema types that have `minOccurs=0` get generated as "wrapper" classes (e.g. `Boolean`) instead of primitives (`boolean`). This is so that the value can be `null` if the XML element is missing or empty.

Based on some non-null-safe legacy code that I'm migrating, it *seems* that earlier versions of JAXB behaved differently, at least under WebSphere 6.1: either using primitives or otherwise returning a default value on empty.

## Bonus topic

A different issue we saw with JAX-WS/JAXB under WAS 8.5.5/Java7, was that `xs:string` values with `xsi:nil="true"`, were sometimes returning null rather than empty string. (Specifically, on the second and subsequent unmarshals. See [forum thread](https://www.ibm.com/developerworks/community/forums/html/topic?id=60ef4f89-701a-447a-9375-3880115eb65a).)

WebSphere 8.5.5 has an optimization option, [com.ibm.xml.xlxp.jaxb.opti.level,](http://www-01.ibm.com/support/knowledgecenter/api/content/SSEQTP_8.5.5/com.ibm.websphere.base.doc/ae/xrun_jvm.html#com.ibm.xml.xlxp.jaxb.opti.level) whose default value exhibits this behavior, but which can be set to a "disabled" value that reverts to the earlier behavior.
