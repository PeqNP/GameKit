# GameKit

GameKit provides a set of middleware tools to make games faster.

## Features

- Decouples your game logic from the Cocos2d-x library. The benefits of this are:
  - Maintain only **one** version of any given version of Cocos2d-x for _every_ game you make. If there is a bug found in your version of Cocos2d-x, patch it in one repository, and then recompile all your games against that version of Cocos2d-x.
  - Much smaller repository sizes for your games. Status quo is to save all of your game's code, assets, etc. in the same repository that contains the Cocos2d-x libs. This is completely unnecessary and quickly becomes unmanageable when you are maintaining any given version of Cocos2d-x.
  - Upgrade to a new version of Cocos2d-x in less than 5 minutes. Download the new version of Cocos2d-x, configure your game to use the latest version, and then run ugf-select. Your game is then ready to start taking advantage of all the latest features and bug fixes.
  - If your game is written entirely in Lua, it will be much easier to port your game to a platform that Cocos2d-x does not support.
- A set of modules to perform common operations such as:
  - Ad Manager: Display ads from a large list of supported mediation networks (AdMob, AdColony, Chartboost, iAd, Leadbolt, Vungle, etc.)
  - The Royal Ad Network: An in-house mediation platform which provides a flexible, robust, ad serving platform.
  - IAP Manager: A flexible API to query and purchase products.
  - Social Manager: Easily integrate with Facebook, Twitter and Weibo
  - App Manager: Manage application related messages including foreground/background messages and notifications
- A model for messaging between client (Lua) and server (native code using the respective Obj-C and Android bridge) layers.
- The Signal Programming Language extension. Signal is an aspect oriented programming language which provides mechanisms to 'tap' into other messages before they are received by the receiver or 'chain' to a receiver, and consume the return value after the message is processed by the receiver. More information will be provided once the API is complete.
- With the "git like" command line interface, GameKit provides a toolchain to facilitate automated builds.

## Design

This diagram provides an overview of the design of GameKit.

![GameKit Design] (https://dl.dropboxusercontent.com/u/55773661/GameKit/Design.png)

## Installation

Install dependencies
```
$ gem install cocoapods --version=0.39.0
$ gem install xcodeproj
$ brew install xcproj
```

Create a directory on your machine where all GameKit supported Git repositories will be saved. This _includes_ any project that uses GameKit.
```
$ mkdir ~/git
$ cd ~/git
```

Clone the GameKit repository.
```
$ git clone https://github.com/PeqNP/GameKit.git
```

Expose the GameKit script files by appending the GameKit/bin path to the system's PATH at the end of you .bashrc (Linux) or .bash_profile (Mac) file.
```
$ vim ~/.bash_profile
export PATH=/Users/eric/git/GameKit/bin:$PATH
```

Source the bashrc file to ensure that PATH is updated.
```
$ source ~/.bash_profile
```

Create a game. This command will create a new game called 'MyGame' with the directory structure that GameKit requires.
```
$ ugf-create MyGame
```

At this point you can configure your game's config file. Here you can change which version of Cocos2d-x your game should use, the name, bundle identifier, etc.
```
$ vim MyGame/config.json
```

Select your game to be the currently selected project that GameKit will use.
```
$ ugf-select MyGame
```
Note: This operation is similar to checking out a branch in git. Only one game can be selected at a time. That being said, it takes less than 5 seconds to checkout most games (this could longer depending on the number of dependencies your game has to download).

This operation will:
- (not complete) Download the version of Cocos2d-x your game requires, if it does not already exist
- Cleans the Cocos2d-x project, if necessary
- (not complete) Download and configure all dependencies. This includes mediation services, analytics libraries, etc.
- Copies GameKit and your project's source code into the Cocos2d-x project

At this point you should be able to open the Cocos2d-x_v#.#.#/frameworks/runtime-src/proj.ios_mac/GameKit-Template.xcworkspace (not the .xccodeproj!) and run your app. (Please note that the '#' must be replaced with the version of Cocos2d-x your project supports; i.e. Cocos2d-x_v3.8.1)

### Android Dependencies Installation

Until some of the other config/download steps are complete, it will be necessary to manually download the following Android dependencies and put them in GameKit-dependencies folder in the base project path. The installer will handle the copy/configure steps.

- adcolony-android-sdk-2.3.1 - https://github.com/AdColony/AdColony-Android-SDK
- facebook-android-sdk-4.9.0 - https://developers.facebook.com/docs/android
- gson-2.6.2.jar - http://search.maven.org/#artifactdetails%7Ccom.google.code.gson%7Cgson%7C2.6.2%7Cjar (Download the .jar file)
- android-ndk-r10c-darwin-x86_64.bin - http://dl.google.com/android/ndk/android-ndk-r10c-darwin-x86_64.bin (Required by Cocos2d-x)
- apache-ant-1.9.6-bin.zip - http://www.trieuvan.com/apache//ant/binaries/apache-ant-1.9.6-bin.zip (Required by Cocos2d-x)
- JRE?

The following dependencies must be downloaded from the Android Studio > SDK Manager:
- (Tab) SDK Tools - Google Play Services (AdMob Ads)
- (Tab) SDK Tools - Google Play Billing Services (IAP)


## Dependencies

GameKit requires the following projects:
- Slightly modified version of Cocos2d-x which integrates GameKit APIs.
- GameKit-iOS
- GameKit-Android (this is not yet complete)

The features that the native GameKit libraries provide is equivalent to Cocos's SDKBOX. The primary differences between the two projects are:
- GameKit is fully tested. This makes GameKit a stable and robust platform.
- More native land related features including application notifications, foreground/background messages, etc.
- A _consistent_ API for every module. Write integration code only once. In addition to this, many of the APIs provide the option to configure which services should be used at run-time. The ad API, for instance, even allows you to download this configuration from a remote host. This provides you with the ability to change how ads are served. More importantly _which_ mediation services to use at any given time.
- Exceptionally easy integration. Add configuration to your respective project files (mediation.json, iap.json, etc.) and GameKit will add only the dependent libraries your project needs.
- GameKit does *NOT* send analytics.
- GameKit is open source and licensed udner the MIT license.

Except for rudimentary Facebook analytic support, GameKit is already feature parity with SDKBOX on the iOS platform. As soon as Android is complete it will be nearly feature parity for both platforms. Analytics and other plugins will be added as needed.

## FAQ

**Q:** Why are you not using Lua's convention to use the built-in table mechanism to create classes?

A trade-off was made to favor speed over memory usage; which is arguably negligible. Using Lua's built-in table mechanism, to create classes, incurs extra message calls when mapping a method call to a respective instance variable. This library does not incur that hit, as the function is associated directly to the 'class' instance. All this being said, I have dabbled with the idea of creating a converter that could, theoritically, transform the classes into the convention used by the majority of the Lua community. For now, the trade-off is justified, as games need to run as fast as possible.
