--[[ Structure provides relationship between a callback and its respective request.

@copyright Upstart Illustration LLC. All rights reserved.

--]]

AdRequestCallback = Class()

function AdRequestCallback.new(self, callback, file, request)
    function self.execute()
        callback(file, request)
    end
end
