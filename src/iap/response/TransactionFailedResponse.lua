--
-- @copyright (c) 2015 Upstart Illustration LLC. All rights reserved.
--

require "bridge.BridgeResponse"

local TransactionFailedResponse = Class(BridgeResponse)

function TransactionFailedResponse.new(self, init)
    local sku

    function self.init(_id, _sku, _e)
        init(false, _id, _e)
        sku = _sku
    end

    function self.getSKU()
        return sku
    end
end

return TransactionFailedResponse
