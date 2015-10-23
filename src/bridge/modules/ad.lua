--
-- @copyright 2015 Upstart Illustration LLC. All rights reserved.
--

local ad = {}

local ndk
function ad.set_ndk(ndk)
    ndk = ndk
end

-- Send

function ad.configure(config)
    return ndk.send("ad__configure", config)
end

function ad.cache(request)
    return ndk.send("ad__cache", request)
end

function ad.show(request)
    return ndk.send("ad__show", request)
end

function ad.destroy(request)
    return ndk.send("ad__destroy", request)
end

-- Receive

function ad__callback_cached(response)
    ndk.receive(response)
end

function ad__callback_presented(response)
    ndk.receive(response)
end

function ad__callback_clicked(response)
    ndk.receive(response)
end

function ad__callback_closed(response)
    ndk.receive(response)
end

function ad__callback_failed(response, err)
    ndk.receive(response, err)
end

return ad
