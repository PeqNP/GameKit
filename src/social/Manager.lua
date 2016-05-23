--
-- @copyright (c) 2016 Upstart Illustration LLC. All rights reserved.
--

local Error = require("Error")
local Promise = require("Promise")
local ConfigureRequest = require("social.ConfigureRequest")
local PostRequest = require("social.PostRequest")
local PostResponse = require("social.PostResponse")

local Manager = Class()

function Manager.new(self)
    local bridge

    function self.init(_bridge)
        bridge = _bridge
    end

    function self.configure(service, config)
        local response = bridge.configure(ConfigureRequest(service, config))
        if response.isSuccess() then
            return true
        end
        return false, Error(1, response.getError())
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
            promise.reject(Error(2, "Unknown error occurred."))
        end)
        return promise
    end
end

return Manager
