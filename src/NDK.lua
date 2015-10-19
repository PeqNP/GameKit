--[[

  @copyright 2015 Upstart Illustration LLC. All rights reserved.

--]]

NDK = Class()

--[[ bridge
if device.platform == "ios" then
    ndk = require "cocos.cocos2d.luaoc"
    controller = "GameController"
    pfunc = iosparams
elseif device.platform == "android" then
    ndk = require "cocos.cocos2d.luaj"
    controller = "org/cocos2dx/lua/AppActivity"
    pfunc = androidparams
end
--]]

function NDK.new(bridge)
    local self = {}

    local delegate

    -- @return Promise
    function self.send(method, args, sig)
    end

    function self.setDelegate(d)
        delegate = d
    end

    function self.getDelegate()
        return delegate
    end

    function self.receive(...)
        -- @todo Find promise and return.
        if delegate and type(delegate["method"]) == "function" then
            delegate["method"](...)
        end
    end

    return self
end
