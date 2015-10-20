
require("ad.AdModule")
require("ad.AdModuleProtocol")

AdMobInterstitial = Class(AdModule)
AdMobInterstitial.implements(AdModuleProtocol)

function AdMobInterstitial.new(self)
    function self.getConfig()
        return nil
    end

    function self.getAdType()
        return AdType.Interstitial
    end

    function self.getNetworkId()
        return AdNetwork.AdMob
    end

    function self.getNetworkName()
        return "AdMob"
    end
end
