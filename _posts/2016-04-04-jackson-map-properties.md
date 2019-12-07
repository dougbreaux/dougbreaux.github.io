---
title: Jackson JSON, "map" properties in WebSphere 8.5.5
tags: [map, wink, websphere, json, jackson, rest, java ]
---
Minor follow-up to [A JSON REST client in WebSphere 8.5]({% post_url 2016-03-04-websphere8.5-json-rest-client %})

I needed to serialize/deserialize name-value properties, ideally into a Java Map. I had hoped this would automatically work, but it does not.

### Useful search results

*   [A Guide to Jackson Annotations](http://www.baeldung.com/jackson-annotations)
*   [JacksonFeatureAnyGetter](http://wiki.fasterxml.com/JacksonFeatureAnyGetter)
*   [Could not read JSON: N/A](http://stackoverflow.com/a/24755563/796761) (at StackOverflow)

### Solution

In my case, the JSON field in question is named 'properties'. It contains name-value string pairs that I want to get into a Map. Inside my POJO, I define:
```java
    private Map<String, String> properties = new HashMap<>();
```
(_See third link above, apparently need to initialize the Map explicitly._)

Then add the following methods, with Jackson-specific annotations:
```java
    @JsonAnyGetter  
    public Map<String, String> getProperties()  
        return properties;  
    }

    @JsonAnySetter  
    public void add(String key, String value) {  
        properties.put(key, value);  
    }
```    

Then a JSON field like this:
```json
      "properties":       {  
         "id": "12345",  
         "notes": "some notes"  
      }
```

Will be deserialized by the Wink client Resource methods into my Map, to be accessed like this:
```java
String id = myJsonResponseBean.getProperties().get("id");
```

### Notes

*   Apparently only one JSON name/value field can be mapped in this way. But this is sufficient for my needs.
*   Regrettably, this is yet another dependency on proprietary APIs. I usually try to avoid those at all costs, but this JSON Client under WebSphere 8.5.5 now has at least 3 of them. There doesn't appear to be an alternative at this point.
*   Surprisingly, [my earlier technique]({% post_url 2016-03-04-websphere8.5-json-rest-client %}) of adding the `@XmlType` and `@JsonIgnoreProperties(ignoreUnknown = true)` annotations to a JsonBase class did not work here. I had to explicitly add those annotations to this POJO class.
