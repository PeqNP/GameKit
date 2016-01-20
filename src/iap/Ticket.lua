--
-- @copyright (c) 2016 Upstart Illustration LLC. All rights reserved.
--

local Ticket = Class()

function Ticket.new(self)
    local productId
    local sku

    function self.init(_productId, _sku)
        productId = _productId
        sku = _sku
    end

    function self.getProductId()
        return productId
    end

    function self.getSKU()
        return sku
    end
end

return Ticket
