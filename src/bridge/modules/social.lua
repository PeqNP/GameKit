--
-- @copyright 2015 Upstart Illustration LLC. All rights reserved.
--

require "json"

local BridgeResponse = require("bridge.BridgeResponse")
local PostResponse = require("social.PostResponse")

local social = {}

local bridge
function social.init(b)
    bridge = b 
end

function social.configure(request)
    local response = bridge.send("social__configure", request, "table")
    return BridgeResponse(response.success, response.id, response.error)
end

function social.post(request)
    local response, call = bridge.sendAsync("social__post", request, "table")
    return BridgeResponse(response.success, response.id, response.error), call
end

function social__completed(payload)
    local response = json.decode(payload)
    bridge.receive(PostResponse(response.id, response.success, response.code, response.error))
end

return social
