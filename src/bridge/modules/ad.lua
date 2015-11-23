--
-- @copyright 2015 Upstart Illustration LLC. All rights reserved.
--

require "ad.AdResponse"

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
    local response = bridge.send("ad__register", config)
    return response
end

-- @return {success:, error:}
function ad.cache(ad)
    local response = bridge.send("ad__cache", ad)
    return response
end

-- @return {success:, error:}
function ad.show(ad)
    local response = bridge.send("ad__show", ad)
    return response
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

function ad__callback(response)
    bridge.receive(AdResponse(response["token"], response["state"], response["error"]))
end

return ad
