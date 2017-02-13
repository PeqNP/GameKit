--
-- Provides function to inject depedencies.
--
-- @copyright 2016 Upstart Illustration LLC. All rights reserved.
--

local ServiceLocator = require("ServiceLocator")

local heroin = {}

local function heroin.inject(dependencyName)
    return function ()
        return ServiceLocator.getDependency(dependencyName)
    end
end

return heroin
