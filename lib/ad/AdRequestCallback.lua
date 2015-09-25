--[[ Structure provides relationship between a callback and its respective request.

@copyright Upstart Illustration LLC. All rights reserved.

--]]

AdRequestCallback = Class()

function AdRequestCallback.new(callback, file, request)
    local self = {}

    function self.execute()
        callback(file, request)
    end
    
    return self
end
