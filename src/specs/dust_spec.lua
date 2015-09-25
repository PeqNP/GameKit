
require "lang.Signal"

require "game.Config"
require "game.particle.Dust"

Singleton(Config, "/path")

describe("Dust", function()
    local subject
    local soundBite

    before_each(function()
        soundBite = Config.singleton.fx.dust
        subject = Dust(soundBite)
    end)

    it("should have set the sound bite", function()
        assert.truthy(subject.getSoundBite())
        assert.equals(soundBite, subject.getSoundBite())
    end)

    -- @fixme added this test to figure out if nextCycle was causing dust-1.mp3
    -- to play.
    describe("nextCycle", function()
        before_each(function()
            subject.nextCycle({}, {})
        end)
    end)
end)
