--
-- Currently all messages are being passed in/out as strings. In the future
-- attempt to support as many VM Type signatures as possible.
-- http://journals.ecs.soton.ac.uk/java/tutorial/native1.1/implementing/method.html
--
-- @copyright (c) 2016 Upstat Illustration LLC. All rights reserved.
--

require("json")

local AndroidAdaptor = Class()
AndroidAdaptor.implements("bridge.BridgeAdaptorProtocol")

function AndroidAdaptor.new(self)
    local adaptor
    local controller

    function self.init(_adaptor, _controller)
        adaptor = _adaptor
        controller = _controller
    end

    local function getArgs(args)
        return args and {json.encode(args)} or {}
    end

    local function getReturn(ret)
        return json.decode(ret)
    end

    local function getSignature(args, ret)
        local P = "" -- Default, no params
        local R = "V" -- Default, 'void' for return
        -- Parameters
        if args then
            P = "Ljava/lang/String;" -- Send parameters as JSON encoded string.
        end
        -- Return
        if ret then
            R = "Ljava/lang/String;" -- Receive parameters as JSON encoded string.
        end
        return string.format("(%s)%s", P, R)
    end

    function self.send(method, args, retType)
        local sig = getSignature(args, retType)
        local argsf = getArgs(args)
        Log.i("BridgeAdaptor:send() - method (%s) retType (%s) args:f (%s) sig (%s)", method, retType, argsf, sig)
        local ok, ret = adaptor.callStaticMethod(controller, method, argsf, sig)
        --[[
          ok - numeric value returned by the native system that indicates the type of error. This is different
          for each platform, apparently. 0 is 'OK' but it's better to just check if the return value is nil.
          That seems to be the one consistent thing between all platforms; is that 'ret' is nil when there is an error.

          ret - converted value, on the native side, to its respective Lua value.
        --]]
        if not ret then
            Log.w("AndroidAdaptor:send(%s, %s, %s) - ok (%s)", method, args, returnType, ok)
            return nil
        end
        Log.d("AndroidAdaptor:send(%s, %s, %s) - ret (%s)", method, args, returnType, ret)
        return getReturn(ret)
    end
end

return AndroidAdaptor
