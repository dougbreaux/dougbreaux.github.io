---
title: Error pattern for REST/HTTP API
tags: [	api, best-practices, rest, http, errors ]
---
Discussing with a customer about how to return errors from our "RESTish" API. (Which has existed for a long time, well predating at least our current awareness of good HTTP API practices). Thought I'd document a few things while they're fresh in my memory...

## HTTP Response Codes

![HTTP status classes](https://www.codetinkerer.com/assets/choosing-an-http-status-code/http-status-classes.png)

I'm already a believer in [using appropriate HTTP response codes](https://www.codetinkerer.com/2015/12/04/choosing-an-http-status-code.html), so that was the first step in revamping the existing API.

## Content Type

My first cut assumed that it would be normal/reasonable for error responses to be a plain text content type. After all, they're just a status code and maybe an explanatory message.

But after looking more at other APIs, and thinking about how a caller would most easily process replies, it seems better and common to use the same Content Type for both normal responses and errors. So that was the next change. Whatever Content Type the caller has requested (our API supports either XML or JSON), that's the format of error responses as well now.

## Single or Multiple Errors?

I thought the norm I'd seen, as a caller, was always a single error returned, so this is what I implemented. But when adding some more sophisticated input field validation ([via JSR 303 annotations, in my case]({% post_url 2018-05-23-springmvc-jsr303-websphere %})), I remembered that as the perfect use case for multiple errors returned together. Like input validation on a web page, so you don't have to correct one-at-a-time.

That presents 3 options:

1.  Always return only one-at-a-time anyway
2.  Always return a list/array, often it will have only one in it
3.  Return either a single or a list, depending on the cases or number of errors

Option 1 fit more with what I thought was normal. And, since for an API, it seems normal to me that input validation errors will often or even usually be worked out and removed during development & integration, this was the direction I was inclined to choose. That is, I don't normally expect an application that is using an API to actually rely solely on the API to do any kind of input limiting/validation. And I still think doing so would at least usually be a poor practice.

Option 2 is what my customer wanted, so this is ultimately what I did. Even though he probably won't be the only customer, he's the first and the only for the foreseeable future. Further, after a little research, I determined that both options 1 and 2 seem to be in common use, with no clearly preferred approach.

To me the downside of this approach is having to semantically decide how to handle things differently, depending on whether there are one or more errors. Or even deciding which calls in which states might truly produce more than one, and which wouldn't.

Option 3 I did see some examples of, in articles describing how to design an API, but I haven't yet found any major APIs using that approach. In these examples, the use case for wanting to report multiple errors at once is the very one I hit: input validation. But being able to handle either case seems an unnecessary complication.

### Examples

My original reason for making this post was to capture the places I'd found that were examples of what APIs did. So, to complete that goal:

*   Looks like [Twitter always returns a list, under an "errors" element](https://developer.twitter.com/en/docs/basics/response-codes).
*   [Facebook seems to be only one](https://developers.facebook.com/docs/graph-api/using-graph-api/error-handling).
*   I think [LinkedIn is only one](https://developer.linkedin.com/docs/guide/v2/error-handling).
*   [Google (Drive, at least; I expect the rest are consistent) seems to be an error wrapping a list of errors](https://developers.google.com/drive/api/v2/handle-errors).
