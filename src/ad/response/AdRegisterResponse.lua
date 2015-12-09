--
-- @copyright 2015 Upstart Illustration LLC. All rights reserved.
--

require "bridge.BridgeResponse"

AdRegisterResponse = Class(BridgeResponse)

function AdRegisterResponse.new(self, init)
    local tokens

    function self.init(_success, _tokens, _err)
        init(_success, _err)
        tokens = _tokens
    end

    function self.getTokens()
        return tokens
    end
end
