--
-- @copyright 2015 Upstart Illustration LLC. All rights reserved.
--

local ad = {}

local bridge
function ad.init(b)
    bridge = b 
end

-- Send

function ad.configure(config)
    return bridge.send("ad__configure", config)
end

function ad.cache(request)
    return bridge.send("ad__cache", request)
end

function ad.show(request)
    return bridge.send("ad__show", request)
end

function ad.destroy(request)
    return bridge.send("ad__destroy", request)
end

-- Receive

function ad__callback(response)
    bridge.receive(response)
end

return ad
