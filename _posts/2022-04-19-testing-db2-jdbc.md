---
published: true
title: Testing DB2 JDBC connectivity
tags:
  - db2
  - jdbc
  - jcc
---
Useful ability to test DB2 JDBC connectivity, given only a JRE and the JCC jar file. 

Found at [https://www.ibm.com/support/pages/stand-alone-test-programs](https://www.ibm.com/support/pages/stand-alone-test-programs)

```console
$ java -cp /path/to/db2jcc4.jar com.ibm.db2.jcc.DB2Jcc -url jdbc:db2://server:60000/database -user dbuser -password $DB_PASSWORD
[jcc][10521][13706]Command : java com.ibm.db2.jcc.DB2Jcc -url jdbc:db2://server:60000/database -user dbuser -password ********
[jcc][10516][13709]Test Connection Successful.
DB product version = SQL110570
DB product name = DB2/LINUXX8664
DB URL = jdbc:db2://sever:60000/database
DB Drivername = IBM Data Server Driver for JDBC and SQLJ
DB OS Name = Linux
```
