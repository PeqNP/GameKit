--
-- @copyright (c) 2016 Upstat Illustration LLC. All rights reserved.
--

local AppleAdaptor = Class()
AppleAdaptor.implements("bridge.BridgeAdaptorProtocol")

function AppleAdaptor.new(self)
    local adaptor
    local controller

    function self.init(_adaptor, _controller)
        adaptor = _adaptor
        controller = _controller
    end

    local function getArgs(params)
        if type(params) ~= "table" then
            return params
        end
        local ret = {}
        for k, v in pairs(params) do
            if type(v) == "table" then -- @fixme this doesn't work.
                ret[tostring(k)] = getArgs(v)
            else
                ret[tostring(k)] = v
            end
        end
        return ret
    end

    function self.send(method, args, returnType)
        --Log.i("BridgeAdaptor:send() - method (%s) args (%s:%s) ret (%s) sig (%s)", method, type(args), args, retType, sig)
        local ok, ret = adaptor.callStaticMethod(controller, method, getArgs(args))
        if not ret then
            Log.w("AppleAdaptor:call(%s, %s, %s) - ok (%s)", method, args, returnType, ok)
            return nil
        end
        return ret
    end
end

return AppleAdaptor
