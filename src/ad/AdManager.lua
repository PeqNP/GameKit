--[[ Provides interface to display ads.

  @copyright 2015 Upstart Illustration LLC. All rights reserved.

--]]

AdManager = Class()

require "ad.Constants"

function AdManager.new(config)
    self = {}

    local delegate
    local networkModules = {}

    function self.getConfig()
        return config
    end

    function self.setDelegate(d)
        delegate = d
    end

    function self.getDelegate()
        return delegate
    end

    --
    -- Register a mediation network w/ provided config.
    -- 
    -- @param AdNetworkModule
    -- 
    function self.registerNetworkModule(module)
        table.insert(networkModules, module)
    end

    function self.getRegisteredNetworkModules()
        return networkModules
    end

    function self.isAdAvailable(adType)
        for _, module in ipairs(networkModules) do
            if module.getAdType() == adType and module.getState() == AdState.Ready then
                return true
            end
        end
        return false
    end

    return self
end
