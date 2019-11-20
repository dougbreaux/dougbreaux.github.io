---
title: Migration/Backup of DeveloperWorks Blog
tags: [ github, wordpress, connections, migration, markdown, blog, jekyll, sunset, developerworks, export ]
---
I was informed a few months ago that IBM DeveloperWorks intends to sunset this instance of IBM Connections, replacing it with an "IBM Communities" site at [https://www.ibm.com/community/](https://www.ibm.com/community/)

As I've been blogging here for 7-8 years, I don't want to lose what I've created. At the moment, there appear to be no plans for migrating my content for me, so I've begun exploring options.

## Exporting the content

First, while there appears to be no way to export content from the web UI, [the Connections API](https://www-10.lotus.com/ldd/lcwiki.nsf/xpAPIViewer.xsp?lookupName=IBM+Connections+5.0+API+Documentation#action=openDocument&res_title=Blogs_API_ic50&content=apicontent) does work, with simple HTTP Basic Authentication, returning me Atom XML documents of my content.

The Blogs I have access to:

 [https://www.ibm.com/developerworks/community/blogs/api?lang=en](https://www.ibm.com/developerworks/community/blogs/api?lang=en)

This particular Blog:

 [https://www.ibm.com/developerworks/community/blogs/Dougclectica/api?lang=en](https://www.ibm.com/developerworks/community/blogs/Dougclectica/api?lang=en)

The first 100 (I only have 75) entries from this Blog:

 [https://www.ibm.com/developerworks/community/blogs/Dougclectica/api/entries?ps=100&lang=en](https://www.ibm.com/developerworks/community/blogs/Dougclectica/api/entries?ps=100&lang=en)

Where each Blog post is an Atom `<entry>` element, with among other things, title, publish date, tags, and content containing the HTML of the post.

And the "media" (e.g. images) can be queried as well, by in my case were just as easy to view and save from the web interface.

## New location

Looking for where to go next (for zero cost),

*   Wordpress.com seems a decent option, and I might end up there. Hard to go wrong with Wordpress
*   Above-mentioned IBM Community might be an option as well, but it's more designed for more official IBM communication. Like my experience here, even if I got it working, I don't have a lot of confidence my case will be important enough to continue being supported long term. Plus, when "one day" I'm no longer IBM, for whatever reason, who knows what would happen to it then.

### GitHub Pages

So for now, I've decided to first try [GitHub Pages](https://pages.github.com/) (with Jekyll). Since most of this stuff is code-y, and I'd even already moved some of my files over there.

So far, it's going to be manual setup for even basic things like a search box or commenting, but we'll see.

### Markdown

Jekyll can use either Markdown or HTML, but you only get nice on-site preview with Markdown, so I've been using [https://www.browserling.com/tools/html-to-markdown](https://www.browserling.com/tools/html-to-markdown) to perform initial conversion.

Yes, doubtless this could all or mostly be done programmatically with APIs, but for a one-time activity, I'm probably not going to go that route.
