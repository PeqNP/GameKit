--[[ Provides configuration an individiual mediation network.

  @copyright 2015 Upstart Illustration LLC. All rights reserved.

--]]

MediationAdConfig = Class()

function MediationAdConfig.new(adnetwork, adtype, adimpressiontype, frequency, reward)
    local self = {}

    self.adnetwork = adnetwork
    self.adtype = adtype
    self.adimpressiontype = adimpressiontype
    self.frequency = frequency
    self.reward = reward

    return self
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
