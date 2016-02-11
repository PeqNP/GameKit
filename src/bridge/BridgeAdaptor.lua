--
-- @since 2015 Upstart Illustration LLC. All rights reserved.
--

require "Logger"

local BridgeAdaptor = Class()

function BridgeAdaptor.new(self)
    local platform
    local controller
    local paramFn
    local returnFn
    local sigFn

    function self.init(p, c, pFn, rFn, sFn)
        platform = p
        controller = c
        paramFn = pFn
        returnFn = rFn
        sigFn = sFn
    end

    function self.send(method, args, retType)
        local sig
        if sigFn then
            sig = sigFn(args, retType)
        end
        local ok, ret = platform.callStaticMethod(controller, method, paramFn(args), sig)
        -- @fixme This needs more definition. The variables returned have no meaning as
        -- to what they do. Apparently, they are also different for every platform.
        if ret == nil then
            return ok
        end
        if rFn then
            return rFn(ret)
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
        return json.encode(params)
    end
    local function androidreturn(ret)
        return json.decode(ret)
    end
    local function androidsig(args, ret)
        local P = {} -- Default, no params
        local R = "V" -- Default, 'void' for return
        -- Parameters
        if args then
            P = "Ljava/lang/String;" -- Send parameters as JSON encoded string.
        end
        -- Return
        if ret then
            R = "Ljava/lang/String;" -- Send parameters as JSON encoded string.
        end
        return string.format("(%s)%s", P, R)
    end

    local adaptor
    local controller
    local paramFn
    local returnFn
    local sigFn
    if platform == "ios" then
        adaptor = require("cocos.cocos2d.luaoc")
        controller = "GKGameRouter"
        paramFn = iosparams
    elseif platform == "android" then
        adaptor = require("cocos.cocos2d.luaj")
        controller = "com.upstartillustration.gamekit.Controller"
        paramFn = androidparams
        returnFn = androidreturn
        sigFn = androidsig
    else
        Log.s("Unable to configure BridgeAdaptor for platform '%s'", platform and platform or "None")
    end

    return BridgeAdaptor(adaptor, controller, paramFn, returnFn, sigFn)
end

return BridgeAdaptor
