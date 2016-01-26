--
-- @copyright (c) 2016 Upstart Illustration LLC. All rights reserved.
--

require "app.request.AppSetupNotificationRequest"

local Manager = Class()

function Manager.new(self)
    local bridge
    local _error

    function self.init(_bridge)
        bridge = _bridge
    end

    function self.setDelegate(delegate)
        bridge.setDelegate(delegate)
    end

    function self.getNotifications()
        local response = bridge.getNotifications()
        if response.isSuccess() then
            return response.getNotifications()
        end
        _error = response.getError()
        return 0
    end

    function self.setupNotification(message, interval)
        local response = bridge.setupNotification(AppSetupNotificationRequest(message, interval))
        if response.isSuccess() then
            return true
        end
        _error = response.getError()
        return false
    end
    
    function self.getError()
        return _error
    end
end

return Manager
