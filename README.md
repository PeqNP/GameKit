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

## Design

This diagram provides an overview of the design of GameKit.

![GameKit Design] (https://dl.dropboxusercontent.com/u/55773661/GameKit/Design.png)

## Installation

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
- Download the version of Cocos2d-x your game requires, if it does not already exist
- Cleans the Cocos2d-x project, if necessary
- Download and configure all dependencies. This includes mediation services, analytics libraries, etc.
- Copies GameKit and your project's source code into the Cocos2d-x project

At this point you should be able to open the Cocos2d-x_v#.#.#/frameworks/runtime-src/proj.ios_mac/GameKit-Template.xcworkspace (not the .xccodeproj!) and run your app. (Please note that the '#' must be replaced with the version of Cocos2d-x your project supports; i.e. Cocos2d-x_v3.8.1)

## Dependencies

GameKit requires the following projects:
- Slightly modified version of Cocos2d-x which integrates GameKit APIs.
- GameKit-iOS
- GameKit-Android (this is not yet complete)

The features that the native GameKit libraries provide is equivalent to Cocos's SDKBOX. The primary differences between the two projects are:
- GameKit is fully tested. This makes GameKit a _much_ more stable and changeable platform. Most new 3rd party services, such as Chartboost, etc. take less than 30 minutes to support.
- More native land related features including application related features such as (notifications, foreground/background messages, etc.)
- A _consistent_ API for every module. Write integration code only once. In addition to this, many of the APIs provide the option to configure which services should be used at run-time. The ad API, for instance, even allows you to download this configuration from a remote host. This provides you with the ability to change how ads are served. More importantly _which_ mediation services to use at any given time.

Except for analytics, GameKit is already feature parity with SDKBOX on the iOS platform. As soon as Android is complete it will be feature parity for both platforms.

Note: GameKit already supports more than twice the number of mediation networks as SDKBOX on iOS as of this writing. It is incredibly easy to support new mediation servies. It takes only 30 minutes to 1 hour to support a new mediation network.

## FAQ

**Q:** Why are you not using Lua's convention to use the built-in table mechanism to create classes?

A trade-off was made to favor speed over memory usage; which is arguably negligible. Using Lua's built-in table mechanism, to create classes, incurs extra message calls when mapping a method call to a respective instance variable. This library does not incur that hit, as the function is associated directly to the 'class' instance. All this being said, I have dabbled with the idea of creating a converter that could, theoritically, transform the classes into the convention used by the majority of the Lua community. For now, the trade-off is justified, as games need to run as fast as possible.

## TODO

