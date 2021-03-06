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

Download and execute the bootstrap script. This downloads all necessary GameKit depenendencies and provides instructions on how to obtain the other necessary dependencies that GameKit (and underlying dependencies such as Cocos2d-x) requries in order to operate.
```
curl -L https://raw.github.com/PeqNP/GameKit/bin/gk-bootstrap | bash
```

**NOTE:** This script provides additional information required to get GameKit running. Follow the instructions, provided at the end of the script's run, which may include adding any paths to your bash(rc|_profile), etc.

After you have performed the configuration steps, as outlined by the script, initialize GameKit by running the following command:
```
$ gk-init
```

This command configures where GameKit will save/search for dependencies and projects.

## Dependencies

GameKit requires the following projects:
- Slightly modified version of Cocos2d-x which integrates GameKit APIs.
- GameKit-iOS
- GameKit-Android

The features that the native GameKit libraries provide is equivalent to Cocos's SDKBOX. The primary differences between the two projects are:
- GameKit is fully tested. This makes GameKit a stable and robust platform.
- More native-land related features including application notifications, foreground/background messages, etc.
- A _consistent_ API for every module. Write integration code only once. In addition to this, many of the APIs provide the option to configure which services should be used at run-time. The ad API, for instance, even allows you to download this configuration from a remote host. This provides you with the ability to change how ads are served. More importantly _which_ mediation services to use at any given time.
- Exceptionally easy integration. Add configuration to your respective project files (mediation.json, iap.json, etc.) and GameKit will add only the dependent libraries your project needs.
- GameKit does *NOT* send analytics.
- GameKit is open source and licensed under the MIT license.

Except for rudimentary Facebook analytic support, GameKit is already feature parity with SDKBOX on the iOS platform. As soon as Android is complete it will be nearly feature parity for both platforms. Analytics and other plugins will be added as needed.

If you wish to use the image manipluation scripts in bin/image-tools you must install the imagemagick libs. On macOS this can be done using brew.
```
$ brew install imagemagick
```

## Testing

GameKit uses `busted`, a BDD testing framework, to test its code. The script `bin/runspecs` can be ran in your project's main directory to easily run your tests. It will ensure all necessary include paths are added to the `busted` command before running your specs.

## FAQ

**Q:** Why are you not using Lua's convention to use the built-in table mechanism to create classes?

A trade-off was made to favor speed over memory usage; which is arguably negligible. Using Lua's built-in table mechanism, to create classes, incurs extra message calls when mapping a method call to a respective instance variable. This library does not incur that hit, as the function is associated directly to the 'class' instance. All this being said, I have dabbled with the idea of creating a converter that could, theoritically, transform the classes into the convention used by the majority of the Lua community. For now, the trade-off is justified, as games need to run as fast as possible.
