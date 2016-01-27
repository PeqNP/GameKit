# GameTools

The GameTools project is many things:
- Decouples Cocos2d-x APIs, with a thin wrapper, from your game logic. This provides the possibility to port your game, if written entirely in Lua, to another game engine where Cocos2d-x is not supported.
- Helper classes to perform common operations:
  - Display ads from a large list of supported mediation networks (AdMob, AdColony, Chartboost, iAd, Leadbolt, Vungle, etc.)
  - The Royal Ad Network; an in-house mediation platform which provides a flexible, robust, ad serving platform.
  - IAP
  - Social integration with Facebook, Twitter and Weibo
  - Application notifications
- A messaging platform to send message to/from client (Lua) and server (native code using the respective Obj-C and Android bridge)
- The Signal Programming Language extension. Signal is a new language designed to provide a programming model suited for making asynchronous message based systems. Games are ideally suited for this type of messaging system. It is an aspect oriented programming language which provides mechanisms to 'tap' into other messages before they are received by the receiver or 'chain' to a receiver, and consume the return value after the message is processed by the receiver. More information will be provided once the API is complete.

## Dependencies

GameTools heavily relies on a proprietary library, created by Upstart Illustration, called GameKit. It is the equivalent to Cocos's SDK Box. The primary differences between the two projects are:
- GameKit is fully tested. This makes GameKit a _much_ more stable and changeable platform.
- A _consistent_ API for every module. Write integration code only once. In addition to this, many of the APIs provide the option to configure which services should be used at run-time. The ad API, for instance, even allows you to download this configuration from a remote host. This provides you with the ability to change how ads are served. More importantly _which_ mediation services to use at any given time.

GameKit is already feature parity with SDK Box on the iOS platform. As soon as Android is complete it will be feature parity for both platforms.

I am currently in the process of trying to figure out how to monetize this library. Either through paid services and consulting or as a paid download.

Note: GameKit already supports more than twice the number of mediation networks as SDK Box on iOS as of this writing. It is incredibly easy to support new mediation servies. It takes only 30 minutes to 1 hour to support a new mediation network.

## FAQ

Why are you not using Lua's convention to use the built-in table mechanism to create classes?
A trade-off was made to favor speed over memory usage; which is arguably negligible. Using Lua's built-in table mechanism, to create classes, incurs extra message calls when mapping a method call to a respective instance variable. This library does not incur that hit, as the function is associated directly to the 'class' instance. All this being said, I have dabbled with the idea of creating a converter that could, theoritically, transform the classes into the convention used by the majority of the Lua community. For now, the trade-off is justified, as games need to run as fast as possible.

## TODO

Make all classes modules. Most classes can be included by doing the following:
```
local ClassName = require("ClassName")
```
The remainder of classes in src/ will eventually be changed.
