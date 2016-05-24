--
-- @copyright (c) 2016 Upstart Illustration LLC. All rights reserved.
--

local Network = Class()

function Network.new(self)
    local name
    local config

    function self.init(_name, _config)
        name = _name
        config = _config
    end

    function self.getName()
        return name
    end

    function self.getConfig()
        return config
    end
end

return Network

