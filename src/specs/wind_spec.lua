
require "lang.Signal"

require "game.Config"
require "game.weather.Wind"

Singleton(Config, "/path")

describe("Wind", function()
    local subject = false
    local soundBite = Config.singleton.fx.wind

    before_each(function()
        subject = Wind(soundBite)
    end)

    it("should have set the SoundBite", function()
        assert.truthy(subject.getSoundBite()) -- sanity; make sure it isn't nil.
        assert.equals(soundBite, subject.getSoundBite())
    end)

    describe("nextCycle", function()
        local cycle = false

        before_each(function()
            subject.nextCycle({}, {})
        end)
    end)
end)
