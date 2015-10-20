--[[ Provides interface to display ads.

  @copyright 2015 Upstart Illustration LLC. All rights reserved.

--]]

require "ad.Constants"

AdManager = Class()

function AdManager.new(adaptor, config)
    local self = {}

    local delegate
    local networkModules = {}
    local _error

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
    -- Starts the process of caching the module.
    -- 
    -- @param AdNetworkModule
    -- 
    function self.registerNetworkModule(module)
        table.insert(networkModules, module)
        -- @todo Start caching the module.
    end

    -- @return AdNetworkModule[]
    function self.getRegisteredNetworkModules()
        return networkModules
    end

    -- @param AdType
    function self.isAdAvailable(adType)
        for _, module in ipairs(networkModules) do
            if module.getAdType() == adType and module.getState() == AdState.Ready then
                return true
            end
        end
        return false
    end

    function self.showAd(adType)
        -- @todo Ask the MediationManager to give us the next ad that should be displayed
        -- for the given type.
        for _, module in ipairs(networkModules) do
            if module.getAdType() == adType and module.getState() == AdState.Ready then
                local promise = adaptor.show(module.generateRequest())
                promise.fail(function(response)
                    --_error = response.error
                end)
                promise.always(function(response)
                    --module.updateState(response.state)
                end)
            end
        end
        return false
    end

    function self.getError()
        return _error
    end

    return self
end
