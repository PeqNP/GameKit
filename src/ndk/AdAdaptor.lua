--
-- @copyright 2015 Upstart Illustration LLC. All rights reserved.
--

local ndk
function ad__set_ndk(ndk)
    ndk = ndk
end

-- Send

function ad__configure(config)
    return ndk.send("ad__configure", config)
end

function self.cache(request)
    return ndk.send("ad__cache", request)
end

function self.show(request)
    return ndk.send("ad__show", request)
end

function self.destroy(request)
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
