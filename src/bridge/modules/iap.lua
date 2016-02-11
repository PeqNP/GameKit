--
-- @copyright 2015 Upstart Illustration LLC. All rights reserved.
--

require "json"

local BridgeResponse = require("bridge.BridgeResponse")
local PurchaseRequest = require("iap.request.PurchaseRequest")
local QueryResponse = require("iap.response.QueryResponse")
local PurchaseResponse = require("iap.response.PurchaseResponse")
local RestorePurchaseResponse = require("iap.response.RestorePurchaseResponse")

local iap = {}

local bridge
function iap.init(b)
    bridge = b 
end

function iap.query(request)
    local response, call = bridge.sendAsync("iap__query", request, "table")
    return BridgeResponse(response.success, response.id, response.error), call
end

function iap.purchase(request)
    local response, call = bridge.sendAsync("iap__purchase", request, "table")
    return BridgeResponse(response.success, response.id, response.error), call
end

function iap.restore()
    local response, call = bridge.sendAsync("iap__restore", nil, "table")
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
