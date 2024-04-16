---
title: Social Bookmarking and Search in Firefox
tags: [firefox,connections,delicious,search,firefox,bookmarks,tagging]
---
Do you use [Delicious](http://www.delicious.com/) or the [Bookmarks service here on DeveloperWorks](https://www.ibm.com/developerworks/community/bookmarks)? Although Social Bookmarking is clearly useful for finding what others have found and sharing what you've found with others, my primary usage is to enable me to find again what I've found in the past.

I bookmark everything I think I might want to find again, even on subjects I don't currently need but might need in the future. A quick, easy search capability makes this a powerful tool. To that end, I use Firefox bookmark Keywords to search tags within bookmarks, all from the URL bar.

[![image](/assets/FirefoxKeywordBookmark-DW.PNG)](/assets/FirefoxKeywordBookmark-DW.PNG)

Then I can type, say,

`mydw jax-rs websphere`

To find everything I've tagged with both "websphere" and "jax-rs". Or

`dw jax-rs websphere`

To find everything everyone on DeveloperWorks has similarly tagged. Here are some search strings to use with both DeveloperWorks' Bookmarks and Delicious:

* `https://www.ibm.com/developerworks/mydeveloperworks/bookmarks/html?lang=en&access=any&userid=0100002GMN&tag=%s`

  Search my own tags. You need to find your own userid by clicking on "My Bookmarks". I use Keyword `mydw`.

* `https://www.ibm.com/developerworks/mydeveloperworks/bookmarks/html?lang=en&access=any&tag=%s`

  Search all DeveloperWorks tags. Keyword `dw`.

* `http://www.delicious.com/&lt;userid&gt;/%s`

  Search user's tags on Delicious.com. Keyword `mydel`.

* `http://www.delicious.com/tag/%s`

  Search all Delicious.com tags. Keyword `del`.

**Bonus Tip:** in many modern browsers, including Firefox, Alt-Enter will open a new tab to display the results of the submitted request. Use that here to bring up your search results in a new tab.
