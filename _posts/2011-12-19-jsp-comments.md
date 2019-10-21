---
title: Basic JEE tip - JSP Comments
tags: [jee,j2ee,comments,html,security,jsp,java]
---
HTML comments are not displayed by a user's browser, but they're available in the source view. JSP comments are removed before the source HTML is returned to the browser.

In many cases where we use comments in our JSPs, we prefer they not appear in the browser-viewable page source. Best case, they're confusing and useless to anybody who looks at them. Worst case, they actually reveal something about our implementation which we'd rather not reveal.

So without further ado:

```html
<!-- HTML Comment -->  
```
```jsp
<%-- JSP Comment --%>  
```
