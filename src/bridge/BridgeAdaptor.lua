--
-- @since 2015 Upstart Illustration LLC. All rights reserved.
--

require "Logger"

local BridgeAdaptor = Class()

function BridgeAdaptor.new(self)
    local platform
    local controller
    local paramFn

    function self.init(p, c, pFn)
        platform = p
        controller = c
        paramFn = pFn
    end

    function self.send(method, args, sig)
        local ok, ret = platform.callStaticMethod(controller, method, paramFn(args), sig)
        -- @fixme This needs more definition. The variables returned have no meaning as
        -- to what they do. Apparently, they are also different for every platform.
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
            return params
        end
        local ret = {}
        for k, v in pairs(params) do
            if type(v) == "table" then -- @fixme this doesn't work.
                ret[tostring(k)] = iosparams(v)
            else
                ret[tostring(k)] = v
            end
        end
        --Log.d("BridgeAdaptor.iosparams -> Returning dictionary")
        return ret
    end

    local function androidparams(params)
        return params
    end

    local adaptor
    local controller
    local paramFn
    if platform == "ios" then
        adaptor = require("cocos.cocos2d.luaoc")
        controller = "AKGameRouter"
        paramFn = iosparams
    elseif platform == "android" then
        adaptor = require("cocos.cocos2d.luaj")
        controller = "org/cocos2dx/lua/AppActivity"
        paramFn = androidparams
    else
        Log.s("Unable to configure BridgeAdaptor for platform '%s'", platform and platform or "None")
    end

    return BridgeAdaptor(adaptor, controller, paramFn)
end

return BridgeAdaptor
