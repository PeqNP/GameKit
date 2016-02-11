--
-- @since 2015 Upstart Illustration LLC. All rights reserved.
--

require "Logger"

local BridgeAdaptor = {}

-- @fixme The 'controller' needs to be pulled from the configuration.
-- Not statically set here.
-- @fixme 'platform' should be an enumeration. Not a string.
function BridgeAdaptor.getAdaptor(platform)
    local adaptor
    if platform == "ios" then
        local AppleAdaptor = require("bridge.adaptor.AppleAdaptor")
        local luaoc = require("cocos.cocos2d.luaoc")
        adaptor = AppleAdaptor(luaoc, "GKGameRouter")
    elseif platform == "android" then
        local AndroidAdaptor = require("bridge.adaptor.AndroidAdaptor")
        local luaj = require("cocos.cocos2d.luaj")
        adaptor = AndroidAdaptor(luaj, "com.upstartillustration.gamekit.Controller")
    else
        Log.s("Unable to configure BridgeAdaptor for platform '%s'", platform and platform or "None")
    end

    return adaptor
end

return BridgeAdaptor
