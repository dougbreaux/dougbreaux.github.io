---
title: iOS Xcodebuild Script
tags: [	xcode, build, cocoapods, ios, xcodebuild, swift ]
---
_Quite a departure from my normal topics, I've had the opportunity to work on an iOS (Swift) app recently (with IBM MobileFirst Platform Foundation handling the server-side logic). Working through various articles and StackOverflow questions to try to find a "happy medium" for the level of build process we needed, I thought what I'd written up for our team could prove useful to others working through something similar._

* TOC
{:toc}

## Goal

Our basic need is for a repeatable build script, that we can commit to Source Control, and that can handle a few differences between "Production" and "Test" builds. We have one distribution mechanism that we use internally, where we produce an ipa file, and we produce an xcarchive for Apple TestFlight or the App Store.

## Useful Links

*   [Migrating iOS App Through Multiple Environments](http://www.blackdogfoundry.com/blog/migrating-ios-app-through-multiple-environments/): more involved process and more capability than what we're currently doing, but good detail about what you might want/need to do
*   [Best way to manage Development, Testing and Production iOS builds with different settings](http://www.developerinsider.in/manage-different-settings-for-development-testing-and-production-ios-builds/): this one offered the crucial advice that if you're using CocoaPods, you need to re-install after creating a new Configuration
*   [Swift Conditional Compilation blocks](https://developer.apple.com/library/content/documentation/Swift/Conceptual/Swift_Programming_Language/Statements.html#//apple_ref/doc/uid/TP40014097-CH33-ID539)
*   Apparently the only current reference for the xcodebuild command-line tool we're using is through the MacOS man pages. The ones I've found online are outdated.
*   [Using xcodebuild To Export a .ipa From an Archive](https://www.thecave.com/2014/09/16/using-xcodebuild-to-export-a-ipa-from-an-archive/): a bit outdated, but original article that enabled us to produce an earlier build script
*   [Read a plist in Swift](http://stackoverflow.com/questions/24045570/swift-read-plist/26333916#26333916)
*   [exportOptionsPlist Q&A](https://stackoverflow.com/a/43154970/796761)
*   [Building from the Command Line with Xcode FAQ](https://developer.apple.com/library/content/technotes/tn2339/_index.html)
*   [Xcode 9 distribution build fails because format of exportOptions.plist has changed in new release](https://stackoverflow.com/questions/45748140/xcode-9-distribution-build-fails-because-format-of-exportoptions-plist-has-chang): additional change since Xcode 9

## Approach Overview

The current approach is very minimal, using only the single default Xcode Scheme, the 2 existing **Debug** and **Release** Configurations, and a new **Test** Configuration copied from the **Release** one.

A few Conditional Compilation code blocks will choose different settings or make different calls, based on which Configuration is being built.

## Xcode Setup

### Create a new Configuration

Under the Project's (not the Target's) **Info** tab, in the Configurations section, we've created an additional **Test** Configuration, copied from "Duplicate Release Configuration".

[![image](https://www.ibm.com/developerworks/community/blogs/Dougclectica/resource/BLOGS_UPLOADED_IMAGES/1.PNG)](https://www.ibm.com/developerworks/community/blogs/Dougclectica/resource/BLOGS_UPLOADED_IMAGES/1.PNG)

Note, also, just below that section, the "Use **Release** for command-line builds". We'll explicitly override it in our build script, but it's worth noting that it exists.

Since we're currently using CocoaPods for the Mobile First SDK, we also had to take the steps described in [the article above](http://www.blackdogfoundry.com/blog/migrating-ios-app-through-multiple-environments/):

> Note that if you use Cocoapods then you will need to set the configurations back to none, delete the contents of the Pods folder in your project (**Not the Pods project**) and re-run `pod install`.

(_I don't know what "set the configurations back to none" means. I didn't do that._)

### Configuration-specific Properties

I think under either the main Project **or** Target, **Build Settings** tab, near the bottom of the tab is the **Swift Compiler - Custom Flags** section. "Inside" that is an **Active Compilation Conditions** subsection. These flags can later be used in Conditional Compilation blocks.

By default, the **Debug** entry has a DEBUG flag set.

We've added a PROD flag to the **Release** entry.

[![image](https://www.ibm.com/developerworks/community/blogs/Dougclectica/resource/BLOGS_UPLOADED_IMAGES/2.PNG)](https://www.ibm.com/developerworks/community/blogs/Dougclectica/resource/BLOGS_UPLOADED_IMAGES/2.PNG)

Note: We're not currently changing the application Bundle ID, name, or icons for the different Configurations. So we won't be able to have multiple builds installed on a device at the same time. It could be useful, but would require quite a bit more effort and complication.

### Change Configurations

When you run an application from within Xcode, you get the **Debug** Configuration by default. If you wish to run in a different Configuration, you can change this by editing the Scheme and changing the selected Configuration for the Run "task". This is a useful way to test your Production settings from the Xcode simulator before building them to push out to a store or device.

[![image](https://www.ibm.com/developerworks/community/blogs/Dougclectica/resource/BLOGS_UPLOADED_IMAGES/3.PNG)](https://www.ibm.com/developerworks/community/blogs/Dougclectica/resource/BLOGS_UPLOADED_IMAGES/3.PNG)[![image](https://www.ibm.com/developerworks/community/blogs/Dougclectica/resource/BLOGS_UPLOADED_IMAGES/4.PNG)](https://www.ibm.com/developerworks/community/blogs/Dougclectica/resource/BLOGS_UPLOADED_IMAGES/4.PNG)[![image](https://www.ibm.com/developerworks/community/blogs/Dougclectica/resource/BLOGS_UPLOADED_IMAGES/5.PNG)](https://www.ibm.com/developerworks/community/blogs/Dougclectica/resource/BLOGS_UPLOADED_IMAGES/5.PNG)

_Note: I think this setting is stored in your user-specific settings, which we've excluded from Git. So it won't want a commit or affect others._

## Build Script

I'm sharing a [simplified version of script itself here](https://www.ibm.com/developerworks/community/files/app#/file/d24e248c-9270-48d7-9dc3-4fa2b9308951). I'll note the main items below.

### Build Configuration

The script currently defaults to building the **Test** Configuration, and you have to specify **Release** on the command-line if you want to build that instead. At a later phase of the project, we might default the other direction.

The script uses three different executions of the `xcodebuild` command:

*   `clean`
*   `archive`
*   `-exportArchive`

(No, I don't know why the first two are commands, and the latter is an option.)

All three have the `-configuration` option explicitly specified, to use either the Configuration name passed-in from the command-line or the default defined in the script itself. I'm not 100% certain all three of them need this, but when only the `clean` command had it (what the referenced article showed), the build did not do what was expected. Which makes sense. It's probably just the archive step that also needs it, but I haven't tested this.

The script also names the archive (the `.xcarchive` directory) MyApp-_ConfigurationName_ if it's not the **Release** Configuration. e.g. MyApp-Test. But the ipa file is always named `MyApp.ipa`. I don't see a way to change this with this configuration. It may be using the Scheme name.

### Scheme

As mentioned above, we still have a single Scheme, so that is hardcoded in the script.

### Workspace

Since CocoaPods projects use an Xcode Workspace rather than a Project, we use the `-workspace` option.

### exportOptionsPlist

Finally, the earlier `-exportFormat` option is now gone, in its place is `-exportOptionsPlist`, which uses a plist file to specify build options. That is currently the file [build.plist](https://www.ibm.com/developerworks/community/files/app#/file/7abd2776-dda8-40bd-9862-b44ec2875321), with the option:

`method=development`

I _think_ since we only build the ipa file when we're deploying through a non-Apple mechanism, we don't need to worry about this when we just pass the xcarchive to Apple.

If we do ever find a need to use different settings here, I think we'd create additional `build-configuration.plist` files(s) and specify the correct one in the script.

_Note: It seems the only reliable way to see the options for the build plist file is to run `xcodebuild -help` on a Mac._

#### _Update for Xcode 9_

For Xcode 9, it seems we now also need to add a `provisioningProfiles` dictionary to the build plist file. [This answer on Stack Overflow](https://stackoverflow.com/a/45888412/796761) provided useful details and an example.

## Code

### Environment-specific Properties

We're using the approach of putting environment-specific properties into application plist files:

*   MyApp-test.plist
*   MyApp-production.plist

For our application, this is currently just a couple of URLs that are different in the two environments. Other items can be added as necessary.

Access to these properties is encapsulated through static methods in a simple AppProperties class, where the next technique is used.

### Conditional Code

Using [Swift Conditional Compilation blocks](https://developer.apple.com/library/content/documentation/Swift/Conceptual/Swift_Programming_Language/Statements.html#//apple_ref/doc/uid/TP40014097-CH33-ID539), we can change which plist files get loaded, omit sections of code, etc.

Note that we're currently only using flags, and we currently only have the DEBUG (created by default in the **Debug** Configuration) and PROD flags available. Our current logic uses only the PROD flag, which is only defined to the **Release** Configuration, so we only have Production vs. non-Production cases today.

Where this is used today is in choosing which application plist to load:
```swift
class AppProperties {  
    #if PROD  
    private static let sharedInstance = AppProperties("MyApp-production")  
    #else  
    private static let sharedInstance = AppProperties("MyApp-test")  
    #endif  
    ...
}
```
