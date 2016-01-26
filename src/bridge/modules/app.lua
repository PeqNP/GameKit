require "bridge.BridgeResponse"

local AppNotificationResponse = require("app.response.AppNotificationResponse")

local app = {}

local bridge
local delegate

function app.init(b)
    bridge = b 
end

function app.setDelegate(d)
    delegate = d
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
    local response = bridge.send("app__setupNotification", request)
    return BridgeResponse(response.success, nil, response.error)
end

function app__didBecomeActive()
    if delegate then
        delegate.appDidBecomeActive()
    end
end

function app__willBecomeInactive()
    if delegate then
        delegate.appWillBecomeInactive()
    end
end

return app
