--
-- @copyright 2015 Upstart Illustration LLC. All rights reserved.
--

require "json"
require "bridge.BridgeResponse"

PurchaseRequest = require("iap.request.PurchaseRequest")
QueryResponse = require("iap.response.QueryResponse")
PurchaseResponse = require("iap.response.PurchaseResponse")
RestorePurchaseResponse = require("iap.response.RestorePurchaseResponse")

local iap = {}

local bridge
function iap.init(b)
    bridge = b 
end

function iap.query(request)
    local response, call = bridge.sendAsync("iap__query", request)
    return BridgeResponse(response.success, response.id, response.error), call
end

function iap.purchase(request)
    local response, call = bridge.sendAsync("iap__purchase", request)
    return BridgeResponse(response.success, response.id, response.error), call
end

function iap.restore()
    local response, call = bridge.sendAsync("iap__restore")
    return BridgeResponse(response.success, response.id, response.error), call
end

function iap__queried(payload)
    local response = json.decode(payload)
    bridge.receive(QueryResponse(response.id, response.products))
end

function iap__purchased(payload)
    local response = json.decode(payload)
    bridge.receive(PurchaseResponse(response.id, response.sku, response.receipt))
end

function iap__restored(payload)
    local response = json.decode(payload)
    bridge.receive(RestorePurchaseResponse(response.id, response.skus))
end

function iap__failed(payload)
    local response = json.decode(payload)
    bridge.receive(BridgeResponse(false, response.id, response.error))
end

return iap
