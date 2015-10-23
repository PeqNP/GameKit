--[[

  @copyright 2015 Upstart Illustration LLC. All rights reserved.

--]]

Bridge = Class()

function Bridge.new(self, bridge)
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
end
