--
-- @copyright (c) 2016 Upstart Illustration LLC. All rights reserved.
--

local AppManager = Class()

function AppManager.new(self)
    local bridge
    local _error

    function self.init(_bridge)
        bridge = _bridge
    end

    function self.getNotifications()
        return 0
    end

    function self.setupNotification(message, interval)
        return false
    end
    
    function self.getError()
        return _error
    end
end

return AppManager
