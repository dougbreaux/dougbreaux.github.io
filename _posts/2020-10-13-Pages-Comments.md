---
published: true
title: Adding Comments to this Blog
tags:
  - github
  - pages
  - jekyll
  - comments
  - utterances
---
## Adding Comment Support to this Blog

After migration my Blog over here (from the defunct IBM DeveloperWorks site), I'd been lacking Search and Comments. I use the [Jekyll Minima theme](https://github.com/jekyll/minima), which has built-in support for Disqus comments, but when I finally decided to try that, I did a quick search on the Privacy implications (having noted that my Privacy add-ons block Disqus by default), and decided [I didn't want to use Disqus after all](https://fatfrogmedia.com/delete-disqus-comments-wordpress/).

Various other options appeared in my searches, including [some](https://darekkay.com/blog/static-site-comments/) [comparisons](https://scottwestover.github.io/post/2020/01/swithcing-to-github-issues-for-comments/) of them. 

One of the clever, clean approaches seems to be [using GitHub Issues to handle the comments](http://donw.io/post/github-comments/). But I really didn't want comments badly enough - at least not at this point - to do the manual work involved.

The 3 that looked most interesting to me were
* [utterances](https://utteranc.es/)
* [Staticman](https://staticman.net/)
* [Gitment](https://github.com/imsun/gitment)

You can see I chose utterances.

## utterances with Jekyll Minima

While Minima has a built-in hook for customizing your blog's header without duplicating all the rest of, it doesn't have one for customizing the post page. I really didn't want to completely overwrite the post page - which would make me have to keep up with changes to it myself - but thought that might be the only option. But it turns out that it was easy enough to pretend I was using Disqus comments and instead override the [disqus_comments.html](https://github.com/dougbreaux/dougbreaux.github.io/blob/master/_includes/disqus_comments.html) page to contain the utterances script.
