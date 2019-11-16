---
title: JAXB @XmlRootElement and JAXBElement<class>
tags: [	jaxb, schema, java, xsd, xml ]
---
Little tip when generating JAXB classes from XML Schema:

> XJC does try to put `@XmlRootElement` annotation on a class that we generate from a complex type. The exact condition is somewhat ugly, but the basic idea is that if we can statically guarantee that a complex type won't be used by multiple different tag names, we put `@XmlRootElement`.

This after I got the error:

`java.lang.ClassCastException: javax.xml.bind.JAXBElement incompatible with my.package.MyType`

### Resolution

Either

1.  Manually change the generated class, if that is appropriate to your workflow. i.e. if you don't need to keep regenerating it over time.
2.  Change the Schema, if possible and appropriate, to put the complexType inside the single element using it
3.  Marshal/Unmarshal with a [wrapper JAXBElement<MyType>](https://stackoverflow.com/a/707122/796761)

Example of #3, with a generic method so it can be used for multiple types:
```java
    private <T> T unmarshalRoot(Reader xmlDocument, Class<T> t) throws JAXBException {  
        Unmarshaller u = context.createUnmarshaller();

        Source s = new StreamSource(xmlDocument);  
        JAXBElement<T> root = u.unmarshal(s, t);  
        T element = root.getValue();  
        return element;  
    }
```

### References

*   Same problem, pointed me to the others: [https://stackoverflow.com/questions/707084/class-cast-exception-when-trying-to-unmarshall-xml](https://stackoverflow.com/questions/707084/class-cast-exception-when-trying-to-unmarshall-xml)
*   Source of that official quote: [http://web.archive.org/web/20090121025810/http://weblogs.java.net/blog/kohsuke/archive/2006/03/why_does_jaxb_p.html](http://web.archive.org/web/20090121025810/http://weblogs.java.net/blog/kohsuke/archive/2006/03/why_does_jaxb_p.html)
*   Helpful explanation of working with JAXB: [https://javaee.github.io/jaxb-v2/doc/user-guide/ch03.html](https://javaee.github.io/jaxb-v2/doc/user-guide/ch03.html)
