--[[ Provides configuration an individiual mediation network.

  @copyright 2015 Upstart Illustration LLC. All rights reserved.

--]]

MediationAdConfig = Class()

function MediationAdConfig.new(self)
    local adNetwork
    local adType
    local adImpressionType
    local frequency
    local reward

    function self.init(_adNetwork, _adType, _adImpressionType, _frequency, _reward)
        adNetwork = _adNetwork
        adType = _adType
        adImpressionType = _adImpressionType
        frequency = _frequency
        reward = _reward
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

    function self.getReward()
        return reward
    end
end

function MediationAdConfig.fromDictionary(dict)
    return MediationAdConfig(
        dict["adnetwork"]
      , dict["adtype"]
      , dict["adimpressiontype"]
      , dict["frequency"]
      , dict["reward"]
    )
end
