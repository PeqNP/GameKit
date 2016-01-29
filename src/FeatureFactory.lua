--
-- @copyright (c) 2016 Upstart Illustration LLC. All rights reserved.
--

local FeatureFactory = Class()

function FeatureFactory.new(self)
    local platform
    local bridge

    function self.init(_platform)
        platform = _platform
    end

    local function getBridge()
        if bridge then
            return bridge
        end
        local Bridge = require("bridge.Bridge")
        local BridgeAdaptor = require("bridge.BridgeAdaptor")
        platform = BridgeAdaptor.getAdaptor(platform)
        bridge = Bridge(platform)
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

    function self.getAdManager(adConfig, networks, adServer)
        local adModule = require("bridge.modules.ad")
        adModule.init(getBridge())

        local service
        if adServer then
            local MediationService = require("mediation.Service")
            service = MediationService(adServer.getHost(), adServer.getPort(), adServer.getPath())
        end

        local AdServerManager = require("ad.ServerManager")
        return AdServerManager(adModule, adConfig, networks, service)
    end

    function self.getSocialManager()
        local SocialManager = require("social.Manager")
        return SocialManager(getBridge())
    end
end

return FeatureFactory
