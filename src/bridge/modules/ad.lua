--
-- @copyright 2015 Upstart Illustration LLC. All rights reserved.
--

require "json"

require "bridge.BridgeResponse"

require "ad.response.AdCacheResponse"
require "ad.response.AdCompleteResponse"
require "ad.response.AdRegisterNetworkResponse"

local ad = {}

local bridge
function ad.init(b)
    bridge = b 
end

-- Send

local function getBridgeResponse(response)
    return BridgeResponse(response.success, nil, response.error)
end

--
-- Configure the services.
--
-- @param AdConfigureRequest
--
function ad.configure(request)
    local response = bridge.send("ad__configure", request)
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
    -- @return {success:, (tokens: OR error:)}
    -- ads[] {token:, zoneId}
    local response = bridge.send("ad__register", request)
    return AdRegisterNetworkResponse(response.success, response.tokens, response.error)
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
    local response, call = bridge.sendAsync("ad__cache", request)
    if type(response) == "table" then
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
    local response, call = bridge.sendAsync("ad__show", request)
    return getBridgeResponse(response), call
end

function ad.hideBannerAd()
    local response = bridge.send("ad__hideBanner")
    return BridgeResponse(response.success, nil, response.error)
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
    --Log.d("ad__cached: token=%s error=%s", response.token, response.error and response.error or "nil")
    bridge.receive(AdCacheResponse(response.token, response.error))
end

function ad__completed(payload)
    local response = json.decode(payload)
    --Log.d("ad__completed: token=%s error=%s", response.token, response.error and response.error or "nil")
    bridge.receive(AdCompleteResponse(response.token, response.reward, response.clicked, response.error))
end

return ad
