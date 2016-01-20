--
-- @copyright (c) 2016 Upstart Illustration LLC. All rights reserved.
--

local Store = Class()

function Store.new(self)
    local tickets
    local products

    function self.init(_tickets, _products)
        tickets = _tickets
        products = _products
    end
end

return Store
