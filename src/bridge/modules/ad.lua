--
-- @copyright 2015 Upstart Illustration LLC. All rights reserved.
--

require "ad.response.AdCacheResponse"
require "ad.response.AdCompleteResponse"

local ad = {}

local bridge
function ad.init(b)
    bridge = b 
end

-- Send

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
    return bridge.send("ad__register", config)
end

-- @return {success:, error:}
function ad.cache(ad)
    return bridge.sendAsync("ad__cache", ad)
end

-- @return {success:, error:}
function ad.show(ad)
    return bridge.sendAsync("ad__show", ad)
end

-- @return {success:, error:}
--function ad.destroy(ad)
--    return bridge.send("ad__destroy", ad)
--end

--
-- Receive
--
-- Configured
-- Registered
-- Cached
-- Presented
-- ?Destroyed
--

-- @todo Could use same response but have a cached/completed state.
function ad__cached(response)
    bridge.receive(AdCacheResponse(response["token"], response["error"]))
end

function ad__completed(response)
    bridge.receive(AdCompletedResponse(response["token"], response["clicked"], response["reward"], response["error"]))
end

return ad
