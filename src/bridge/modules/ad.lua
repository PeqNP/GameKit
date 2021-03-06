--
-- @copyright 2015 Upstart Illustration LLC. All rights reserved.
--

require "json"

local BridgeResponse = require("bridge.BridgeResponse")
local AdCacheResponse = require("ad.response.AdCacheResponse")
local AdCompleteResponse = require("ad.response.AdCompleteResponse")
local AdRegisterNetworkResponse = require("ad.response.AdRegisterNetworkResponse")

local ad = {}

local bridge
function ad.init(b)
    bridge = b 
end

-- Send

local function getBridgeResponse(response)
    return BridgeResponse(response.success, response.id, response.error)
end

--
-- Configure the services.
--
-- @param AdConfigureRequest
--
function ad.configure(request)
    local response = bridge.send("ad__configure", request, "table")
    return BridgeResponse(response.success, nil, response.error)
end

--
-- Register an ad network and its respective ads with the system.
--
-- @param AdRegisterNetworkRequest
--
-- @return AdRegisterNetworkResponse
--
function ad.register(request)
    -- A typical request looks like:
    -- {network: "AdColony", appid: "vcz-123456789", ads: [{"type": AdType.Interstitial, "zoneid": "abcd-12345"}]}
    -- @return {success:, (adids: OR error:)}
    -- ads[] {adid:, zoneId}
    local response = bridge.send("ad__register", request, "table")
    return AdRegisterNetworkResponse(response.success, response.adids, response.error)
end

--
-- Cache an ad.
--
-- @param id<AdRequest>
--
-- @return BridgeResponse
--
function ad.cache(request)
    -- @return {success:, error:}
    local response, call = bridge.sendAsync("ad__cache", request, "table")
    if type(response) == "table" then -- Occurs when call failed.
        return getBridgeResponse(response), call
    end
    return BridgeResponse(false, nil, "Failed to cache ad"), call
end

--
-- Show an ad.
--
-- @param id<AdRequest>
--
-- @return BridgeResponse
--
function ad.show(request)
    -- @return {success:, error:}
    local response, call = bridge.sendAsync("ad__show", request, "table")
    return getBridgeResponse(response), call
end

function ad.hideBannerAd()
    local response = bridge.send("ad__hideBanner", nil, "table")
    return getBridgeResponse(response)
end

--function ad.destroy(ad)
--    -- @return {success:, error:}
--    return bridge.send("ad__destroy", ad)
--end

--
-- Receive
--

function ad__cached(payload)
    local response = json.decode(payload)
    Log.d("ad__cached: success=%s id=%s reward=%s error=%s", response.success, response.id, response.reward and response.reward or 0, response.error and response.error or "nil")
    bridge.receive(AdCacheResponse(response.success, response.id, response.reward, response.error))
end

function ad__completed(payload)
    local response = json.decode(payload)
    Log.d("ad__completed: success=%s id=%s error=%s", response.success, response.id, response.error and response.error or "nil")
    bridge.receive(AdCompleteResponse(response.success, response.id, response.reward, response.clicked, response.error))
end

return ad
