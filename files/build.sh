#!/bin/bash
appName=MyApp
fullAppName=$appName

configuration=${1:-Test}
if [ $configuration != 'Release' ]; then
    fullAppName=$appName-$configuration
fi

rm $appName.ipa
rm -rf $fullAppName.xcarchive

# use date for build number
buildnum=$(date -u "+%Y%m%d.%H%M%S")
echo "Building build number $buildnum for app $appName"

# official way to set build version
agvtool new-version -all $buildnum

xcodebuild clean -configuration $configuration -alltargets
xcodebuild archive -archivePath $fullAppName.xcarchive -workspace $appName.xcworkspace -scheme "MyAppScheme" -configuration $configuration OBJROOT=$(PWD)/build SYMROOT=$(PWD)/build

# build ipa file
xcodebuild -exportArchive -archivePath $fullAppName.xcarchive -configuration $configuration -exportPath . -exportOptionsPlist build.plist
echo "Built build number $buildnum for App $appName with Configuration $configuration"

# "revert" to prior, unchanged CFBundleVersion so we don't have to make a new commit for every build
git checkout $appName/Info.plist
