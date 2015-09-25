
require "lang.Signal"

require "Logger"

require "game.Particle"

describe("Particle", function()
    local subject
    local soundBite

    before_each(function()
        soundBite = {}
        subject = Particle(soundBite)
    end)

    it("should have set the sound bite", function()
        assert.equals(soundBite, subject.getSoundBite())
    end)
end)
