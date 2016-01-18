--
-- @copyright (c) 2016 Upstart Illustration LLC. All rights reserved.
--

require "Promise"
require "Error"

local PostRequest = require("social.PostRequest")
local PostResponse = require("social.PostResponse")

local Manager = Class()

function Manager.new(self)
    local bridge

    function self.init(_bridge)
        bridge = _bridge
    end

    -- @param string - Service to post to. Supported: Twitter, Facebook and Baidu
    function self.post(service, message, image, resource)
        local promise = Promise()
        local response, call = bridge.post(PostRequest(service, message, image, resource))
        call.done(function(response)
            if response.isSuccess() then
                promise.resolve()
            else
                promise.reject(Error(response.getCode(), response.getError()))
            end
        end)
        call.fail(function()
            promise.reject(Error(500, "Unknown error occurred."))
        end)
        return promise
    end
end

return Manager
