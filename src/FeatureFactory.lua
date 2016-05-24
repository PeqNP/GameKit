--
-- @copyright (c) 2016 Upstart Illustration LLC. All rights reserved.
--

local FeatureFactory = Class()

function FeatureFactory.new(self)
    local http
    local platform
    local contentScaleFactor

    local bridge

    function self.init(_http, _platform, _contentScaleFactor)
        http = _http
        platform = _platform
        contentScaleFactor = _contentScaleFactor
    end

    local function getBridge()
        if bridge then
            return bridge
        end
        local Bridge = require("bridge.Bridge")
        local BridgeAdaptor = require("bridge.BridgeAdaptor")
        local adaptor = BridgeAdaptor.getAdaptor(platform)
        bridge = Bridge(adaptor)
        return bridge
    end

    function self.getAppManager()
        local appModule = require("bridge.modules.app")
        appModule.init(getBridge())

        local AppManager = require("app.Manager")
        return AppManager(appModule)
    end

    function self.getIAP(tickets)
        local iapModule = require("bridge.modules.iap")
        iapModule.init(getBridge())

        local IAPManager = require("iap.Manager")
        local iapManager = IAPManager(iapModule)

        local IAP = require("iap.IAP")
        return IAP(iapManager, tickets)
    end

    function self.getAdManager(adConfig, networks, url)
        local adModule = require("bridge.modules.ad")
        adModule.init(getBridge())

        local service
        if url then
            local MediationService = require("mediation.Service")
            service = MediationService(http, url)
        end

        local AdServerManager = require("ad.ServerManager")
        return AdServerManager(adModule, adConfig, networks, service)
    end

    function self.getSocialManager(networks)
        local sbridge = require("bridge.modules.social")
        sbridge.init(getBridge())
        local SocialManager = require("social.Manager")
        local manager = SocialManager(sbridge)
        for _, network in ipairs(networks) do
            manager.configure(network)
        end
        return manager
    end

    local function getImageVariant()
        if platform == "android" or contentScaleFactor == 1.0 then
            return "hd"
        end
        return "xhd"
    end

    --
    -- Returns a Royal client which can be used download Royal ad config from
    -- a remote server.
    --
    -- This method has the side-effect of loading cached config!
    --
    function self.getRoyalClient(config, url)
        local AdConfig = require("royal.AdConfig")
        local AdManifest = require("royal.AdManifest")
        local Client = require("royal.Client")

        local client = Client(http, config, url)

        Log.i("Initializing the Royal Ad Network...")
        config.setImageVariant(getImageVariant())
        -- @todo Load default config from file and return it. It will be used when
        -- queried...? or maybe this is done
        local jsonStr = config.read(config.getConfigFilename())
        if jsonStr then
            local manifest = AdManifest.fromJson(jsonStr)
            if manifest then
                Log.i("FeatureFactory:getRoyalClient() - Loaded cached manifest from disk")
                client.setCachedManifest(manifest)
            end
        end
        return client
    end
end

return FeatureFactory
