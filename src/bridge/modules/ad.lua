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

local function getAdTokens(response)
    if not response.ads then
        return {}
    end
    local ads = {}
    for _, ad in ipairs(response.ads) do
        local a = AdToken(ad.token, ad.zoneid)
        table.insert(ads, a)
    end
    return ads
end

local function getAdResponse(response)
    return AdResponse(response.success, response.error)
end

--
-- Register an ad network and its respective ads with the system.
--
-- A typical request looks like:
-- {network: "AdColony", appid: "vcz-123456789", ads: [{"type": AdType.Interstitial, "zoneid": "abcd-12345"}]}
--
-- @return dictionary{success:, error:, ads: [{str token:, str zoneid:} ... ]} List of tokenz/zoneide pairs.
--
function ad.register(config)
    -- success
    -- ads[] {token:, zoneId}
    local response = bridge.send("ad__register", config)
    return AdRegisterResponse(response.success, getAdTokens(response))
end

function ad.cache(ad)
    -- @return {success:, error:}
    local response, call = bridge.sendAsync("ad__cache", ad)
    return getAdResponse(response), call
end

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
