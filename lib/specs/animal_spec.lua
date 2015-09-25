require "lang.Signal"

require "specs.Cocos2d-x"
require "specs.fixtures.Level"

require "Common"
require "Logger"
require "Sound"

require "game.Animal"
require "game.Config"

Singleton(Config, "/path")
Singleton(Sound)

Log.setLevel(LogLevel.Severe)

describe("Animal", function()
    local subject
    local soundBite
    local depth

    before_each(function()
        soundBite = Config.singleton.fx.precipitation[1]
        depth = LevelDepth.Near
        subject = Animal(soundBite)
    end)

    it("should have set the SoundBite", function()
        assert.equals(soundBite, subject.getSoundBite())
    end)

    describe("start", function()
        local level

        before_each(function()
            level = Level1()
            subject.start(level)
        end)

        it("should have set the level", function()
            assert.equals(level, subject.getLevel())
        end)
    end)

end)
