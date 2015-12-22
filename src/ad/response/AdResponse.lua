--
-- @copyright (c) 2015 Upstart Illustration LLC. All rights reserved.
--

require "bridge.BridgeResponse"

AdResponse = Class(BridgeResponse)

function AdResponse.new(self, init)
    function self.init(success, err)
        init(success, nil, err)
    end
end

