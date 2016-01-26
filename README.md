# GameTools

The GameTools project is many things:
- Decouples Cocos2d-x's APIs to provide an easy transition to port your game, written in Lua, to another game engine where Cocos2d-x is not supported.
- Helper classes to perform common operations:
  - Display ads from a very large list of supported mediation networks (AdMob, AdColony, Chartboost, iAd, Leadbolt, Vungle, etc.)
  - The Royal Ad Network; an in-house mediation platform which provides a flexible, robust ad serving platform.
  - IAP
  - Social integration with Facebook, Twitter and Weibo
  - Application notifiations
- A messaging platform to send message to/from client (Lua) and server (native code using the respective Obj-C and Android bridge)
- The Signal Programming Language extension. Signal is a new language designed to provide a programming model suited for making asynchronous message based systems. Games are ideally suited for this type of messaging system. It is an aspect oriented programming language which provides mechanisms to 'tap' into other messages before they are received by the receiver or 'chain' to a receiver, and consume the return value after the message is processed by the receiver.

## FAQ

Why are you not using Lua's convention to use the built-in table mechanism to create classes?
A trade-off was made to favor speed over memory usage; which is arguably negligible. Using Lua's built-in table mechanism, to create classes, incurs extra message calls when mapping a method call to a respective instance variable. This library does not incur that hit, as the function is associated directly to the 'class' instance. All this being said, I have dabbled with the idea of creating a converter that could, theoritically, transform the classes into the convention used by the majority of the Lua community. For now, the trade-off is justified, as games need to run as fast as possible.

## TODO

- Make all classes modules. All of the newer classes can be included by using local ClassName = require("ClassName"). This follows the latest conventions used by Lua.
