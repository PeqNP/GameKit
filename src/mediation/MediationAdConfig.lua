--[[ Provides configuration an individiual mediation network.

  @copyright 2015 Upstart Illustration LLC. All rights reserved.

--]]

MediationAdConfig = Class()

function MediationAdConfig.new(self)
    local adNetwork
    local adType
    local adImpressionType
    local frequency
    local impression
    local click

    function self.init(_adNetwork, _adType, _adImpressionType, _frequency, _impression, _click)
        adNetwork = _adNetwork
        adType = _adType
        adImpressionType = _adImpressionType
        frequency = _frequency
        impression = _impression
        click = _click
    end

    function self.getAdNetwork()
        return adNetwork
    end

    function self.getAdType()
        return adType
    end

    function self.getAdImpressionType()
        return adImpressionType
    end

    function self.getFrequency()
        return frequency
    end

    function self.getRewardForImpression()
        return impression
    end

    function self.getRewardForClick()
        return click
    end
end

function MediationAdConfig.fromDictionary(dict)
    return MediationAdConfig(
        dict["adnetwork"]
      , dict["adtype"]
      , dict["adimpressiontype"]
      , dict["frequency"]
      , dict["impression"]
      , dict["click"]
    )
end
