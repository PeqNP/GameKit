--
-- @copyright 2015 Upstart Illustration LLC. All rights reserved.
--

require "json"
require "bridge.BridgeResponse"

TransactionRequest = require("iap.request.TransactionRequest")
TransactionCompletedResponse = require("iap.response.TransactionCompletedResponse")
TransactionFailedResponse = require("iap.response.TransactionFailedResponse")

local iap = {}

local bridge
function iap.init(b)
    bridge = b 
end

function iap.purchase(request)
    local response = bridge.send("iap__purchase", request)
    return BridgeResponse(response.success, response.id, response.error)
end

function iap.restore(request)
    local response = bridge.send("iap__restore", request)
    return BridgeResponse(response.success, response.id, response.error)
end

function iap__completed(payload)
    local response = json.decode(payload)
    bridge.receive(TransactionCompletedResponse(response.id, response.productid, response.receipt))
end

function iap__restored(payload)
    local response = json.decode(payload)
    bridge.receive(TransactionCompletedResponse(response.id, response.productid, response.receipt))
end

function iap__failed(payload)
    local response = json.decode(payload)
    bridge.receive(TransactionFailedResponse(response.id, response.error))
end

return iap
