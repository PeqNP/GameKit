--[[ Structure provides relationship between a callback and its respective request.

@copyright Upstart Illustration LLC. All rights reserved.

--]]

AdRequestCallback = Class()

function AdRequestCallback.new(self)
    local callback
    local file
    local request

    function self.init(_callback, _file, _request)
        callback = _callback
        file = _file
        request = _request
    end

    function self.execute()
        callback(file, request)
    end
end
