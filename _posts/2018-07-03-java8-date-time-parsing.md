---
title: "New Java 8 date/time classes: parsing to older classes, with Time Zone"
tags: [	java, java.time, sql, time, timestamp, date, timezone, java8 ]
---
Quick info about my foray into new `java.time` classes, because they offer [the ability to have "optional" components in their format strings](https://stackoverflow.com/a/26132715/796761).

Which we wanted because apparently the C# .NET code that one of our customers uses [will omit the milliseconds part of a timestamp if it is zero](https://stackoverflow.com/questions/18193281/force-json-net-to-include-milliseconds-when-serializing-datetime-even-if-ms-com). Which `java.text.SimpleDateFormat` doesn't handle. Customer is willing to remove milliseconds entirely, but since we don't know exactly when, this approach puts things under our control.

But moving to these new classes wasn't as simple (for me) as I had expected, so I wanted to document what ended up working for me, I admit through a combination of StackOverflow and trial-and-error. And possibly even revealing my ignorance of a better approach...

In this case, our code still wants a `java.sql.Timestamp` field, in the JVM's Time-zone (which we usually set to UTC), from a "string" date/time field that is in the customer's (Arizona) Time Zone. There may have been an easier way if we could use something other than `java.sql.Timestamp`, but I was trying to impact as little code as possible.

Here's the relevant code:
```java
    // unlike SimpleDateFormat, DateTimeFormatter instance is thread-safe, so can share one</span>  
    // ofPattern() for custom pattern. There are several built-in, but not what we needed  
    // [.SSS] makes milliseconds optional  
    // withZone() to get formatter/parser in AZ time  
    public static final java.time.DateTimeFormatter TZ_FORMATTER = DateTimeFormatter.ofPattern(
        "yyyy-MM-dd'T'HH:mm:ss[.SSS]").withZone(java.time.ZoneId.of("America/Phoenix"));

    ...  

    // ZonedDateTime includes TZ information. LocalDateTime does not
    java.time.ZonedDateTime zdt = ZonedDateTime.parse(dateString, TZ_FORMATTER);  

    // withZoneSameInstant() keeps the same "instant" in time, shift to another TZ</span>  
    // ZoneId.systemDefault() to pick up the JVM default TZ (surprised there wasn't a default method)  
    java.time.ZonedDateTime sysdt = zdt.withZoneSameInstant(ZoneId.systemDefault());  

    // Timestamp (and Date) has no TZ. toLocalDateTime() converts  
    // new java.sql.Timestamp.valueOf() method to convert from java.time.LocalDateTime  
    java.sql.Timestamp ts = Timestamp.valueOf(sysdt.toLocalDateTime());
```
