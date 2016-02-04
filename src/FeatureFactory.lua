--
-- @copyright (c) 2016 Upstart Illustration LLC. All rights reserved.
--

local LuaFile = require("LuaFile")
local HTTP = require("shim.HTTP")

local FeatureFactory = Class()

function FeatureFactory.new(self)
    local platform
    local contentScaleFactor
    local file
    local http

    local bridge

    function self.init(_platform, _contentScaleFactor)
        platform = _platform
        contentScaleFactor = _contentScaleFactor
        file = LuaFile()
        http = HTTP()
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
    function self.getRoyalClient(writablePath, url)
        local AdConfig = require("royal.AdConfig")
        local Client = require("royal.Client")

        Log.i("Initializing the Royal Ad Network...")
        local config = AdConfig(writablePath)
        config.setImageVariant(getImageVariant())
        -- @todo Load default config from file and return it. It will be used when
        -- queried...? or maybe this is done
        local jsonStr = file.read(config.getPlistFilepath())
        if jsonStr then
            local manifest = AdManifest.fromJson(jsonStr)
            if manifest then
                Log.i("FeatureFactory:getRoyalClient() - Loaded cached manifest from disk")
                config.setCachedManifest(manifest)
            end
        end
        return Client(http, file, config, url)
    end
end

return FeatureFactory
