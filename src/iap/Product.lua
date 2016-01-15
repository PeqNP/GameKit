--
-- @copyright (c) 2016 Upstart Illustration LLC. All rights reserved.
--

local Product = Class()

function Product.new(self)
    local sku
    local title
    local description
    local price

    function self.init(_sku, _title, _description, _price)
        sku = _sku
        title = _title
        description = _description
        price = _price
    end

    function self.getSKU()
        return sku
    end

    function self.getTitle()
        return title
    end

    function self.getDescription()
        return description
    end

    function self.getPrice()
        return price
    end
end

return Product
