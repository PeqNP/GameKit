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
-- Configure a mediation network.
--
-- A typical request looks like:
-- {network: "AdColony", appid: "vcz-123456789", ads: [{"type": AdType.Interstitial, "zoneid": "abcd-12345"}]}
--
-- @return dictionary{success:, error:, ads: [{str token:, str zoneid:} ... ]} List of tokenz/zoneide pairs.
--
function ad.configure(config)
    return bridge.send("ad__configure", config)
end

-- @return {success:, error:}
function ad.cache(request)
    return bridge.send("ad__cache", request)
end

-- @return {success:, error:}
function ad.show(request)
    return bridge.send("ad__show", request)
end

-- @return {success:, error:}
function ad.destroy(request)
    return bridge.send("ad__destroy", request)
end

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
