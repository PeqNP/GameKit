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

    function self.fromDictionary(dict)
        self.adnetwork = dict["adnetwork"]
        self.adtype = dict["adtype"]
        self.adimpressiontype = dict["adimpressiontype"]
        self.frequency = dict["frequency"]
        self.reward = dict["reward"]
    end

    return self
end
