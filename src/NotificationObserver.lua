--
-- @copyright 2015 Upstart Illustration LLC. All rights reserved.
--

local NotificationObserver = Class()

function NotificationObserver.new(self)
    function self.init(observer, callback)
        self.observer = observer
        self.callback = callback
    end
end

return NotificationObserver
