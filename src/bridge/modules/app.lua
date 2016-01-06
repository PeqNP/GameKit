local app = {}

local bridge

function app.init(b)
    bridge = b 
end

local function getBridgeResponse(response)
    return BridgeResponse(response.success, nil, response.error)
end

--
-- Returns the number of notifications that have been sent to the user.
-- On iOS, this is the badge number.
--
function app.getNotifications()
    return getBridgeResponse(bridge.send("app__getNotifications"))
end

-- @param AppSetupNotificationRequest
function app.setupNotification(request)
    return getBridgeResponse(bridge.send("app__setupNotifiation", request))
end

return app
