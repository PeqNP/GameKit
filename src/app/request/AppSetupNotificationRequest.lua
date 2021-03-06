--
-- @copyright (c) 2015 Upstart Illustration LLC. All rights reserved.
--

local AppSetupNotificationRequest = Class()
AppSetupNotificationRequest.implements("bridge.BridgeRequestProtocol")

function AppSetupNotificationRequest.new(self)
    local message
    local interval

    function self.init(_message, _interval)
        message = _message
        interval = _interval
    end

    function self.toDict()
        return {message=message, interval=interval}
    end
end

return AppSetupNotificationRequest
