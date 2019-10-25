---
title: Using a Template Engine from your Java code
tags: [html,template,velocitytools,java,velocity,stringtemplate]
---
![image](http://velocity.apache.org/engine/releases/velocity-1.7/images/velocity-logo.png)Several times we've needed to retain output files which are a mix of static HTML and dynamic data.

In some of those cases, we've wanted to capture the same HTML (or a subset of it) which was returned to a user's browser as a normal HTTP response. While that's made me wish for a programmatic way to call the JSP engine, we ended up using a custom Filter to just capture the HTML on the way out, and that's worked well enough.

However, we now have a desire to capture merged HTML into standalone files that are not related to HTTP request or response processing. So rather than hardcode the HTML creation, I decided to start using one of the existing template engines. [Velocity](http://velocity.apache.org/), [FreeMarker](http://freemarker.sourceforge.net/), and [StringTemplate](http://www.stringtemplate.org/) are 3 of the most used. One of my main requirements was that the template files be true HTML that would syntax-check successfully in an IDE or code editor.

#### Generic Interface

Without going into how I selected (it's not real concrete, but there are several comparisons on StackOverflow), I decided to further pursue both Velocity and StringTemplate, so I wanted to start with a generic interface, using their implementations to help me decide which of the two I'd use. _Remember, we're not using a template engine to replace our JSP/JSTL "view" rendering, just for merging static & dynamic data to create a handful of specific files we need to retain._  

```java
import java.util.Map;  

/**  
* Merge static "templates" with dynamic data. Implementations could be custom or could make use  
* of 3rd-party template engines.  
*/  
public interface TemplateMerger
{  
    /**  
     * Merge a group of data objects into a template, specified by name.  
     * @param templateName name of an object (e.g. file) which contains the template to be filled  
     * @return Merged data  
     * @throws MergeException if the merge fails for any reason (e.g. IOException reading a file).  
     * Implementations should probably instead throw RuntimeExceptions for cases which are  
     * caused by coding bugs, such as specifying a particular template but failing to provide  
     * a data object required by that template.  
     */  
    String merge(String templateName, Map<String, ?> <string, ?="">dataObjects) throws MergeException;  

    /**  
     * Merge a group of data objects into a pattern specified in a String literal.  
     * @param pattern necessarily specific to the TemplateMerger implementation  
     * @return Merged data  
     */  
    String mergeLiteral(String pattern, Map<String, ?> <string, ?="">dataObjects);  
}
```

In the end, I had to choose, and for various reasons I chose Velocity. Here are both versions, although the StringTemplate version is a little less capable because I stopped working with it after I chose Velocity.

#### StringTemplate Implementation

```java
import java.util.Map;

import org.stringtemplate.v4.ST;
import org.stringtemplate.v4.STRawGroupDir;

/**
 * Implementation using StringTemplate Template Engine.
 * @see http://www.stringtemplate.org/
 */
public class StringTemplateMerger implements TemplateMerger
{
    private String dirName;

    private STRawGroupDir dir;

    public void init() {
        // STRawGroupDir, allowing plain HTML files as templates, didn't appear until version 4.0.5
        // http://www.antlr.org/wiki/display/ST4/4.0.5+Release+Notes
        dir = new STRawGroupDir(getDirName(), '$', '$');
    }

    public String merge(String templateName, Map<String, ?> dataObjects) throws MergeException {
        ST template = dir.getInstanceOf(templateName + ".html");
        if (template == null) {
            throw new MergeException();
        }
 
        addDataObjects(dataObjects, template);

        return template.render();
    }

    public String mergeLiteral(String pattern, Map<String, ?> dataObjects) {
        ST template = new ST(pattern, '$', '$');
        addDataObjects(dataObjects, template);
        return template.render();
    }

    protected void addDataObjects(Map<String, ?> dataObjects, ST template) {
        for (Map.Entry data : dataObjects.entrySet()) {
            template.add(data.getKey(), data.getValue());
        }
    }

    public String getDirName() {
        return dirName;
    }

    /**
     * StringTemplate loads template files from a base directory which can be either a regular File
     * directory or a Classpath Resource directory. It will first look for a directory File from the
     * specified directory name, and if that doesn't exist try the classpath.
     */
    public void setDirName(String dirName) {
        this.dirName = dirName;
    }
}
```

#### Velocity Implementation

One of the reasons I chose Velocity was that I could use the existing [VelocityTools](http://velocity.apache.org/tools/releases/2.0/) extensions to, for instance, format Date values in different ways, so you can see my use of the [DateTool](http://velocity.apache.org/tools/releases/2.0/javadoc/org/apache/velocity/tools/generic/DateTool.html) object in this implementation.  

```java
import java.io.File;
import java.io.StringWriter;
import java.util.HashMap;
import java.util.Map;
import java.util.Properties;
import java.util.TimeZone;

import org.apache.velocity.Template;
import org.apache.velocity.VelocityContext;
import org.apache.velocity.app.Velocity;
import org.apache.velocity.exception.ResourceNotFoundException;
import org.apache.velocity.tools.generic.DateTool;

/**
 * Implementation using the Apache Velocity engine.
 * @see http://velocity.apache.org/
 */
public class VelocityMerger implements TemplateMerger
{
    private String dirName;

    /** For date formatting */
    private TimeZone timeZone;

    private Map<String, String> dateToolConfig = new HashMap<String, String>();

    public void init() {
        File dir = new File(getDirName());
        if (dir == null || !dir.exists() || !dir.isDirectory() || !dir.canRead()) {
            throw new RuntimeException("Template Directory " + getDirName() + " is invalid.");
        }

        Properties properties = new Properties();
        properties.setProperty(Velocity.FILE_RESOURCE_LOADER_PATH, getDirName());
        Velocity.init( properties );
    }

    public String merge(String templateName, Map<String, ?> dataObjects) throws MergeException {
        try {
            Template template = Velocity.getTemplate(templateName + ".html");

            VelocityContext ctx = fillContext(dataObjects);

            StringWriter out = new StringWriter();
            template.merge(ctx, out);
            return out.toString();
        }
        catch (ResourceNotFoundException e) {
            throw new MergeException(e.getMessage());
        }
    }

    public String mergeLiteral(String pattern, Map<String, ?> dataObjects) {
        VelocityContext ctx = fillContext(dataObjects);

        StringWriter out = new StringWriter();
        Velocity.evaluate(ctx, out, "mergeLiteral", pattern);
        return out.toString();
    }

    protected VelocityContext fillContext(Map<String, ?> dataObjects) {
        VelocityContext ctx = new VelocityContext();

        DateTool date = new DateTool();
        date.configure(dateToolConfig);
        ctx.put("date", date);

        for (Map.Entry data : dataObjects.entrySet()) {
            ctx.put(data.getKey(), data.getValue());
        }
        return ctx;
    }

    public String getDirName() {
        return dirName;
    }
    public void setDirName(String dirName) {
        this.dirName = dirName;
    }

    public TimeZone getTimeZone() {
        return timeZone;
    }
    public void setTimeZone(TimeZone timeZone) {
        this.timeZone = timeZone;
        dateToolConfig.put(DateTool.TIMEZONE_KEY, timeZone.getID());
    }
}
```
