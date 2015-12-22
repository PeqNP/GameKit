--
-- @copyright 2015 Upstart Illustration LLC. All rights reserved.
--

require "json"

TransactionRequest = require("iap.request.TransactionRequest")
TransactionResponse = require("iap.response.TransactionResponse")
TransactionCompletedResponse = require("iap.response.TransactionCompletedResponse")
TransactionFailedResponse = require("iap.response.TransactionFailedResponse")

local iap = {}

local bridge
function iap.init(b)
    bridge = b 
end

function iap.purchase(request)
    local response = bridge.send("iap__purchase", request)
    return TransactionResponse(response.id, response.success, response.error)
end

function iap.restore(request)
    local response = bridge.send("iap__restore", request)
    return TransactionResponse(response.id, response.success, response.error)
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
    bridge.receive(TransactionFailedResponse(response.id, response.success, response.error))
end

return iap
