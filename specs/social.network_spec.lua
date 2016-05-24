require "specs.busted"
require "specs.Cocos2d-x"
require "lang.Signal"

local SocialNetwork = require("social.Network")

describe("social.Network", function()
    local subject
    local config

    before_each(function()
        config = {appkey="123", secret="secret"}
        subject = SocialNetwork("Twitter", config)
    end)

    it("should return the correct property values", function()
        assert.equal("Twitter", subject.getName())
        assert.equal(config, subject.getConfig())
    end)
end)
