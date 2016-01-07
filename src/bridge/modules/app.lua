require "app.response.AppNotificationResponse"
require "bridge.BridgeResponse"

local app = {}

local bridge

function app.init(b)
    bridge = b 
end

--
-- Returns the number of notifications that have been sent to the user.
-- On iOS, this is the badge number.
--
function app.getNotifications()
    local response = bridge.send("app__getNotifications")
    return AppNotificationResponse(response.success, response.notifications, response.error)
end

-- @param AppSetupNotificationRequest
function app.setupNotification(request)
    local response = bridge.send("app__setupNotifiation", request)
    return BridgeResponse(response.success, nil, response.error)
end

return app
