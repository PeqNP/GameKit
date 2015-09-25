
require "lang.Signal"

require "Logger"

require "game.TerraCycle"
require "game.animal.Frog"

describe("Frog", function()
    local subject
    local soundBite

    before_each(function()
        soundBite = {}
        subject = Frog(soundBite)
    end)

    it("should have set the sound bite", function()
        assert.equals(soundBite, subject.getSoundBite())
    end)

    it("should return false", function()
        assert.falsy(subject.getInterval(nil, nil))
    end)
end)

describe("Frog.getMaxAllowedForTerraCycle", function()
    it("should have zero allowed animals", function()
        assert.equals(0, Frog.getMaxAllowedForTerraCycle())
    end)
end)
