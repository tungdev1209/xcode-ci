# ios-ci

## Description
Build, archive, export,... iOS/MacOS app via command line.   

## Requirements
xcodebuild

## Install
brew install ios-ci

## Initialize
```sh
$ cd path/to/ios/project
$ ios-ci init
```
Ex:
```sh
$ cd /Users/tungdev1209/Projects/iOS/HelloWorld
$ ios-ci init
```
## Adjust default value
After initialized, .deploy dir is created automatically, then you have to adjust params in both deploy_config.json and export_config.plist (ignore this file if you just want to archive)

=> ./deploy_config.json
```
{
    "project_path":".",
    "archive_path":"./Archive",
    "archive_scheme":"HelloWorld"
}
```

=> ./export_config.plist
```
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>compileBitcode</key>
	<true/>
	<key>method</key>
	<string>enterprise</string>
	<key>provisioningProfiles</key>
	<dict>
		<key>com.tungdev1209.helloworld</key>
		<string>70f47xxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx</string>
	</dict>
	<key>signingCertificate</key>
	<string>iPhone Distribution</string>
	<key>signingStyle</key>
	<string>manual</string>
	<key>stripSwiftSymbols</key>
	<true/>
	<key>thinning</key>
	<string>&lt;none&gt;</string>
</dict>
</plist>
```

## Command
Syntax: 
```sh
$ ios-ci <cmd>
```
* init [-f]       : Initialize deploy components (-f force re-init)
* -a              : Archive
* -e              : Export
* --version       : show the version

Have fun!
