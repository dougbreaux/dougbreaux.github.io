---
title: Firefox Tip - Using Multiple Profiles
tags: [ plugins, firefox, extensions, add-ons ]
---
![image](https://mozorg.cdn.mozilla.net/media/img/styleguide/identity/firefox/usage-logo.png?2013-06)

Stumbled across this write-up I'd done years ago for my colleagues. Nothing revolutionary about it, but I thought I'd share in case others who see this are unaware of the capability.

Firefox stores user-specific data in [Profiles](https://support.mozilla.org/en-US/kb/profiles-where-firefox-stores-user-data). Bookmarks, settings, add-ons, etc. By default, Firefox creates and uses just one Profile, and you might not even know of its existence. But you can create and explicitly run more than one Profile, each with different configurations, and each running in a separate process. (On your traditional workstation, that is. Not, as far as I know, on a "mobile" device.) I typically use 2 or 3 Profiles for different purposes.

"Why?", you might ask. In short, some of my add-ons are specifically for development-oriented tasks, and aren't useful or necessary for my normal browsing activities. And since each such add-on increases Firefox's memory usage and adds its own risks of bugs and memory leaks, I decided to try a whole separate Profile for development tasks.

(Another, more recent option, is the [Firefox Developer Edition](https://www.mozilla.org/en-US/firefox/developer/), which installs a newer, test version of Firefox as an additional application, includes some developer-oriented settings, and also uses a separate Profile.)

A side-benefit is the ability to manage my active list of "browsing" pages separately from my development pages, restarting the browser and restoring the tabs, etc.

Next, how do you use multiple profiles?  I won't attempt to duplicate the details described thoroughly in [these](http://kb.mozillazine.org/Profile_Manager) [articles](http://kb.mozillazine.org/Opening_a_new_instance_of_your_Mozilla_application_with_another_profile), but here's a quick summary:

![image](/assets/FirefoxProfileManager.png)

1.  Run the firefox executable with the command-line options "-P -no-remote".  This opens the Profile Manager and tells Firefox not to attempt to connect to an already-running copy.  

2.  Create a new profile.  I left the "Don't ask at startup" box checked so that just running Firefox by itself opens my default profile without asking.  

3.  Create a custom shortcut to launch your new profile.  Here's the text for my "Developer" profile:  

    `"C:\Program Files\Mozilla Firefox\firefox.exe" -P Developer -no-remote`

In the screenshot, you can also see my "ESR" profiles for the [Extended Support Release](https://www.mozilla.org/en-US/firefox/organizations/) version of Firefox that I have installed alongside the current, Release version. This is the enterprise version of Firefox that my employer, IBM, officially supports for employees.

I also have some "Clean" profiles that I can use when I need to test how a site is behaving on a "stock" Firefox installation, without any customizations or add-ons.
