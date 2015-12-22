--
-- @copyright 2015 Upstart Illustration LLC. All rights reserved.
--

require "bridge.BridgeResponse"

AdRegisterNetworkResponse = Class(BridgeResponse)

function AdRegisterNetworkResponse.new(self, init)
    local tokens

    local function getTokens(_tokens)
        if not _tokens then
            return {}
        end
        local parts = string.split(_tokens, ",")
        local parsed = {}
        for _, part in ipairs(parts) do
            table.insert(parsed, tonumber(part))
        end
        return parsed
    end

    function self.init(_success, _tokens, _err)
        init(_success, nil, _err)
        tokens = getTokens(_tokens)
    end

    function self.getTokens()
        return tokens
    end
end
