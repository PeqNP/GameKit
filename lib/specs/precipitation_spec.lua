
require "lang.Signal"

require "game.Config"
require "game.weather.Precipitation"

describe("Precipitation", function()
    local subject
    local soundBite

    before_each(function()
        soundBite = {}
        subject = Precipitation(soundBite, 10)
    end)

    it("should have set the SoundBite", function()
        assert.truthy(subject.getSoundBite()) -- sanity; make sure it isn't nil.
        assert.equals(soundBite, subject.getSoundBite())
    end)

    it("should have set the strength", function()
        assert.equals(10, subject.getStrength())
    end)

    describe("nextCycle", function()
        local cycle = false

        before_each(function()
            subject.nextCycle(Season.Vernal, DayCycle.Evening)
        end)

        it("should have changed the strength to ?", function()
        end)
    end)
end)
