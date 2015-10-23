--
-- @since 2015 Upstart Illustration LLC. All rights reserved.
--

require "Logger"

BridgeAdaptor = Class()

function BridgeAdaptor(self, platform, controller, paramFn)
    function self.send(method, args, sig)
        local ok, ret = platform.callStaticMethod(controller, method, paramFn(args), sig)
        if ret == nil then
            return ok
        end
        return ret
    end
end

-- @fixme The 'controller' needs to be pulled from the configuration.
-- Not statically set here.
-- @fixme 'platform' should be an enumeration. Not a string.
function BridgeAdaptor.getAdaptor(platform)
    local function iosparams(params)
        if type(params) ~= "table" then
            Log.d("iosparams -> Not a table")
            return params
        end
        local ret = {}
        for k,v in pairs(params) do
            if type(k) == "table" then
                Log.d("iosparams -> Dictionary passed")
                return params
            end
            ret[tostring(k)] = v
        end
        Log.d("iosparams -> Returning dictionary")
        return ret
    end

    local function androidparams(params)
        return params
    end

    local platform
    if platform == "ios" then
        platform = require("cocos.cocos2d.luaoc")
        controller = "GameController"
        pfunc = iosparams
    elseif platform == "android" then
        platform = require("cocos.cocos2d.luaj")
        controller = "org/cocos2dx/lua/AppActivity"
        pfunc = androidparams
    end

    return BridgeAdaptor(platform, controller, paramFn)
end
