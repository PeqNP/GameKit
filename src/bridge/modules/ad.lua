--
-- @copyright 2015 Upstart Illustration LLC. All rights reserved.
--

require "ad.AdToken"

require "ad.response.AdCacheResponse"
require "ad.response.AdCompleteResponse"
require "ad.response.AdRegisterResponse"
require "ad.response.AdResponse"

local ad = {}

local bridge
function ad.init(b)
    bridge = b 
end

-- Send

local function getAdResponse(response)
    return AdResponse(response.success, response.error)
end

--
-- Register an ad network and its respective ads with the system.
--
-- @param AdNetwork
--
-- @return AdRegisterResponse
--
function ad.register(network)
    -- A typical request looks like:
    -- {network: "AdColony", appid: "vcz-123456789", ads: [{"type": AdType.Interstitial, "zoneid": "abcd-12345"}]}
    -- @return {success:, (tokens: OR error:)}
    -- ads[] {token:, zoneId}
    local response = bridge.send("ad__register", network.getConfig())
    return AdRegisterResponse(response.success, response.tokens and response.tokens or {}, response.error)
end

--
-- Cache an ad.
--
-- @param Ad
--
-- @return AdResponse
--
function ad.cache(ad)
    -- @return {success:, error:}
    local response, call = bridge.sendAsync("ad__cache", ad)
    return getAdResponse(response), call
end

--
-- Show an ad.
--
-- @param Ad
--
-- @return AdResponse
--
function ad.show(ad)
    -- @return {success:, error:}
    local response, call = bridge.sendAsync("ad__show", ad)
    return getAdResponse(response), call
end

--function ad.destroy(ad)
--    -- @return {success:, error:}
--    return bridge.send("ad__destroy", ad)
--end

--
-- Receive
--

function ad__cached(response)
    bridge.receive(AdCacheResponse(response["token"], response["error"]))
end

function ad__completed(response)
    bridge.receive(AdCompleteResponse(response["token"], response["reward"], response["clicked"], response["error"]))
end

return ad
