---
title: SoapUI dynamic date parameter
tags: [ rest, date, parameter, soapui, groovy ]
---
Quick/brief post on putting a dynamic date into a (REST) parameter in a SoapUI request.

SoapUI supports Groovy scripting. See [https://www.soapui.org/scripting---properties/property-expansion.html#2-Dynamic-Properties](https://www.soapui.org/scripting---properties/property-expansion.html#2-Dynamic-Properties)

My specific desire was to be able to pass "tomorrow's date" as a dynamic parameter. Thanks to the help of the SoapUI forums:

[http://community.smartbear.com/t5/SoapUI-Open-Source/Dynamic-date-REST-parameter/td-p/115467](http://community.smartbear.com/t5/SoapUI-Open-Source/Dynamic-date-REST-parameter/td-p/115467)

I'm able specify this snippet as the value of my date (template) parameter:
```groovy
${=def now = new Date();now++;now.format("yyyy-MM-dd")}
```

## Notes:

* Among other things, apparently Groovy [automatically imports common packages/classes](http://groovy-lang.org/structure.html), like `java.util`
