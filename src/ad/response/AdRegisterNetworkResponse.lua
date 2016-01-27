--
-- @copyright 2015 Upstart Illustration LLC. All rights reserved.
--

local AdRegisterNetworkResponse = Class("bridge.BridgeResponse")

function AdRegisterNetworkResponse.new(self, init)
    local adIds

    local function getAdIds(_adIds)
        if not _adIds then
            return {}
        end
        local parts = string.split(_adIds, ",")
        local parsed = {}
        for _, part in ipairs(parts) do
            table.insert(parsed, tonumber(part))
        end
        return parsed
    end

    function self.init(_success, _adIds, _err)
        init(_success, nil, _err)
        adIds = getAdIds(_adIds)
    end

    function self.getAdIds()
        return adIds
    end
end

return AdRegisterNetworkResponse
