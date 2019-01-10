# ios-ci

## Description
Build, Archive, Export,... iOS/MacOS app via command line.   

## Requirements
xcodebuild

## Install
```sh
$ brew tap tungdev1209/ios-ci
$ brew install ios-ci
```
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
    "archive_scheme":"HelloWorld",
    "build_path":"./Build",
    "build_scheme":"HelloWorld",
    "archive_args":"",
    "export_args":"",
    "build_args":"-sdk iphonesimulator -configuration Debug ONLY_ACTIVE_ARCH=NO clean"
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
* ```init [-f]``` - Initialize deploy components (```-f``` force re-init)
* ```-a 'archive args'``` : Additional Archive command arguments (plus archive_args value in deploy_config.json in order to make final Archive command)
* ```-e 'export args'``` : Additional Export command arguments (plus export_args value in deploy_config.json in order to make final Export command)
* ```-b 'build args'``` : Additional Build command arguments (plus build_args value in deploy_config.json in order to make final Build command)
* ```-t``` : Add test to Build command
* ```-fw 'u.d.s'``` : Indicate this is the framework project, ```'u'``` if you just want to export Universal framework, ```'d'``` => Device framework and ```'s'``` => Simulator framework, ```'u.d'``` if you would both Universal & Device frameworks. Default: export all kind of frameworks if you just ```-fw```, if you don't ```-fw```, **ios-ci** understand this is normal application project
* ```-r 'b.a.e'``` : Indicate whether ci process will be run or not, ```'b'``` if you just want to run Build process, ```'a'``` => Archive process and ```'e'``` => Export process, ```'a.e'``` if you would like to run Archive and then Export process. Default: run all kind of processes one by one (Build -> Archive -> Export) if you don't type ```-r```
* ```--version``` : show the version

## Hooks
```sh
$ ios-ci
```
Above cmd means: **ios-ci** will run all of the processes one by one (Build -> Archive -> Export) with config files (deploy_config.json and export_config.plist). Before and after each process, **ios-ci** allow you add more processes you would like to run via ./hooks file
* pre_build.sh
* post_build.sh
* pre_archive.sh
* post_archive.sh
* pre_export.sh
* post_export.sh

## Example:
'The right example is worth 1000 lines of documentation'. I belive it!

=> For normal project:
```sh
$ ios-ci -r 'b'
```
=> For framework project:
```sh
$ ios-ci -fw 'u.d' -r 'a.e'
```

**=> Be careful, because ios-ci add more process args by 2 ways, via command line (-a -e -b) and via deploy_config.json, and the final process cmd-line will merge all args at 2 places, processes will be fail if one of the args appear twice**

Have fun!
