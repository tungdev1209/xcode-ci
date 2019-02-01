# xcode-ci

## Description
CI iOS/MacOS app via command line.   

## Requirements
xcodebuild

## Install
```sh
$ brew tap tungse1209/xcode-ci
$ brew install xcode-ci
```
## Initialize
```sh
$ cd path/to/ios/project
$ xcode-ci init
```
Ex:
```sh
$ cd /Users/tungse1209/Projects/iOS/HelloWorld
$ xcode-ci init
```
## Adjust default value
After initialized, .ci dir is created automatically, then you have to adjust params in both deploy_config.json and export_config.plist (ignore this file if you don't want to export)

=> ./.ci/deploy_config.json
```
{
    "project_path":".",
    "project_name":"HelloWorld.xcodeproj",
    "build_path":"./Build",
    "build_scheme":"HelloWorld",
    "archive_path":"./Archive",
    "archive_scheme":"HelloWorld",
    "build_args":"clean",
    "test_args":"",
    "archive_args":"",
    "export_args":""
}
```

=> ./.ci/export_config.plist
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
		<key>com.tungse1209.helloworld</key>
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
$ xcode-ci <command>
```
* ```init [-f/--force]``` : Initialize ci components (```-f``` force re-init)
* ```-b/--build 'build args'``` : Additional Build command arguments (plus build_args value in deploy_config.json in order to make final Build command)
* ```-t/--test 'test args'``` : Additional Test command arguments (plus test_args value in deploy_config.json in order to make final Test command)
* ```-a/--archive 'archive args'``` : Additional Archive command arguments (plus archive_args value in deploy_config.json in order to make final Archive command)
* ```-e/--export 'export args'``` : Additional Export command arguments (plus export_args value in deploy_config.json in order to make final Export command)
* ```-fw/--framework 'u.d.s'``` : Indicate this is the framework project, ```'u'``` if you just want to export Universal framework, ```'d'``` => Device framework and ```'s'``` => Simulator framework, ```'u.d'``` if you would both Universal & Device frameworks. Default: export all kind of frameworks if you just ```-fw```, if you don't ```-fw```, **ios-ci** understand this is normal application project
* ```-r/--run 'b.t.a.e'``` : Indicate whether ci process will be run or not, ```'b'``` if you just want to run Build process, ```'t'``` => Test process, ```'a'``` => Archive process and ```'e'``` => Export process, ```'a.e'``` if you would like to run Archive and then Export process. Default: run all kind of processes one by one (Build -> Test -> Archive -> Export) if you don't type ```-r```
* ```-v/--version``` : show the version

## Default arguments
By default, **ios-ci** detect current type of project you would like to build (whether project or workspace) by project_name value (whether .xcodeproj or .xcworkspace) in deploy_config.json in order to make final Build command

* Build : ```-project/-workspace project_path/project_name -scheme build_scheme -sdk iphonesimulator -configuration Debug ONLY_ACTIVE_ARCH=NO build```
* Test : same default Build args + ```test```
* Archive : ```-project/-workspace project_path/project_name -scheme archive_scheme -archivePath archive_path/archive_scheme.xcarchive -configuration Release archive```
* Export : ```-exportArchive -archivePath archive_path/archive_scheme.xcarchive -exportOptionsPlist ./.ci/export_config.plist -exportPath archive_path/export_path``` (export_path: auto generate each time **ios-ci** run Export process)

You could override above args via deploy_config.json and **ios-ci** command   

## Hooks
```sh
$ xcode-ci
```
Above command means: **ios-ci** will run all of the processes one by one (Build -> Test -> Archive -> Export) with config files (deploy_config.json and export_config.plist). Before and after each process, **ios-ci** allow you add more processes you would like to run via ./hooks file
* pre_build.sh
* pre_test.sh
* post_build.sh
* post_test.sh
* pre_archive.sh
* post_archive.sh
* pre_export.sh
* post_export.sh

## Example:
'The right example is worth 1000 lines of documentation'. I belive it!

=> For normal project:
```sh
$ xcode-ci -r 'b'
```
=> For framework project:
```sh
$ xcode-ci -fw 'u.d' -r 'a.e'
```

## License
This project is licensed under the terms of the MIT license.


Have fun!
