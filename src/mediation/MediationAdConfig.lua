--[[ Provides configuration an individiual mediation network.

  @copyright 2015 Upstart Illustration LLC. All rights reserved.

--]]

MediationAdConfig = Class()

function MediationAdConfig.new(self, adnetwork, adtype, adimpressiontype, frequency, reward)
    self.adnetwork = adnetwork
    self.adtype = adtype
    self.adimpressiontype = adimpressiontype
    self.frequency = frequency
    self.reward = reward
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
