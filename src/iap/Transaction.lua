--
-- @copyright (c) 2016 Upstart Illustration LLC. All rights reserved.
--

local Transaction = Class()

function Transaction.new(self)
    local sku
    local receipt

    function self.init(_sku, _receipt)
        sku = _sku
        receipt = _receipt
    end

    function self.getSKU()
        return sku
    end
    
    function self.getReceipt()
        return receipt
    end
end

return Transaction
