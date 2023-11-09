---
published: true
tags:
  - json
  - jq
  - scripting
title: Parsing JSON with jq
---
[`jq`](https://jqlang.github.io/jq/) is such a useful, powerful tool for parsing the JSON data that many APIs produce.

Albeit perhaps a bit cryptic in syntax (much like regex). But there's also this fantastic playground at [jqplay.org](https://jqplay.org/) for testing options and producing the command syntax for you.

(Side note, if you're on Windows and have installed Git for Windows, `jq` is part of the install!)

### Selecting fields from an array

My particular need was to get the results of an API call that produces an array of "allowed" values for a data field - Country codes in this case - and convert that into a list of name-value pairs for use elsewhere.

Using [this comment in a GitHub Issue](https://github.com/jqlang/jq/issues/2247#issuecomment-760543007) as a clear example, with JSON data like the following: 

```json
{
    "result": [
        {
            "countryId": "1",
            "countryCode": "AF",
            "countryCode2": "AFG",
            "countryDisplayValue": "Afghanistan",
            "countryDescription": "Afghanistan",
            "active": "True",
            "updatedDate": "1/15/2020 12:45:00 PM"
        },
        {
            "countryId": "2",
            "countryCode": "AX",
            "countryCode2": "ALA",
            "countryDisplayValue": "Aland Islands",
            "countryDescription": "Aland Islands",
            "active": "True",
            "updatedDate": "1/15/2020 12:45:00 PM"
        },
...
```

We can use this `jq` filter to merge two fields with an equals sign between them:

`.result[] | "\(.countryCode)=\(.countryDisplayValue)"`

Or the following `jq` command:

```shell
$ jq --raw-output '.result[] | "\(.countryCode)=\(.countryDisplayValue)"'
```

Output like:
```properties
AF=Afghanistan
AX=Aland Islands
```