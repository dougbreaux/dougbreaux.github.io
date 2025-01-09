---
published: true
title: 'Controlling log4j Log Level at Runtime, 2.0'
tags:
  - log4j
  - java
  - log4j2
---
Follow-up to [earlier post]({% post_url 2013-06-05-log4j-log-level %}), adjusted for log4j version 2, this time in XML configuration:

Default to `INFO` level logging, override with System property `logj4.logLevel` if it exists.

```xml
<?xml version="1.0" encoding="UTF-8"?>
<Configuration status="INFO">

  ...
  
    <Loggers>
        <Root level="${sys:log4j.logLevel:-INFO}">
            <appender-ref ref="DailyRollingFile"/>
        </Root>
    </Loggers>
  
</Configuration>
```
