--[[ Provides configuration an individiual mediation network.

  @copyright 2015 Upstart Illustration LLC. All rights reserved.

--]]

MediationAdConfig = Class()

function MediationAdConfig.new(self, adNetwork, adType, adImpressionType, frequency, reward)
    self.adnetwork = adNetwork
    self.adtype = adType
    self.adimpressiontype = adImpressionType
    self.frequency = frequency
    self.reward = reward

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
