--
-- @copyright 2015 Upstart Illustration LLC. All rights reserved.
--

local AppNotificationResponse = Class("bridge.BridgeResponse")

function AppNotificationResponse.new(self, init)
    local notifications

    function self.init(_success, _notifications, _err)
        init(_success, nil, _err)
        notifications = _notifications
    end

    function self.getNotifications()
        return notifications
    end
end

return AppNotificationResponse
