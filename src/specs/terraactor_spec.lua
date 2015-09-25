
require "lang.Signal"

require "specs.Cocos2d-x"
require "specs.fixtures.Level"

require "Common"
require "Sound"
require "Logger"

require "game.SaveState"
require "game.TerraActor"
require "game.animal.Bird"
require "game.Config"
require "game.FXProcessor"

Singleton(Config, "/path")
Singleton(Sound)

--Log.setLevel(LogLevel.Warning)

describe("TerraActor", function()
    local subject
    local soundBite
    local season
    local dayCycle

    before_each(function()
        soundBite = Config.singleton.fx.precipitation[1]
        subject = TerraActor(soundBite)
    end)

    it("should have set the SoundBite", function()
        assert.truthy(subject.getSoundBite())
        assert.equals(soundBite, subject.getSoundBite())
    end)

    it("should have no location", function()
        assert.falsy(subject.getLocation())
    end)

    describe("start", function()
        local level
        local origin

        before_each(function()
            cu.getOrigin = function()
                return origin
            end
            origin = 0

            level = Level1()
            subject.start(level)
        end)

        it("should have set the level", function()
            assert.equals(level, subject.getLevel())
        end)

        it("should set the sound's pan near the center", function()
            --Log.e("getSoundAttr pan (%d) gain (%d)", subject.getSoundAttr())
        end)

        describe("setLocation", function()
            before_each(function()
                location = cu.p3(40, 0, 1)
                subject.setLocation(location)
            end)

            it("should have set the location", function()
                assert.equals(location, subject.getLocation())
            end)
        end)

        describe("changeLocation", function()
            local location1
            local location2

            before_each(function()
                subject.changeLocation()
                location1 = subject.getLocation()
                subject.changeLocation()
                location2 = subject.getLocation()
            end)

            it("should have set the location1", function()
                assert.truthy(location1)
            end)

            it("should have changed the location when called again", function()
                assert.not_equals(location1, location2)
            end)
        end)

        -- @fixme Shouldn't this prevent starting again until stopped?
        describe("start again", function()
            local level2

            before_each(function()
                level2 = Level2()
                subject.start(level2)
            end)

            it("should have set to level2", function()
                assert.equals(level2, subject.getLevel())
            end)
        end)

        describe("nextCycle", function()
            before_each(function()
                subject.nextCycle({}, {})
            end)
        end)

        describe("stop", function()
            before_each(function()
                subject.stop()
            end)

            it("should have set the level to nil", function()
                assert.falsy(subject.getLevel())
            end)
        end)

        describe("updateAudio", function()
            local fx

            before_each(function()
                fx = FXProcessor(cc.size(50, 100))
                fx.setPoint(cc.p(-25, 0))
            end)

            describe("when the actor is in view", function()
                before_each(function()
                    stub(soundBite, "setAttributes")

                    subject.setLocation(cu.p3(40, 0, 1))
                    subject.updateAudio(fx)
                end)

                it("should have set correct pan and gain to 1", function()
                    assert.stub(soundBite.setAttributes).was_called_with(-0.4, 1)
                end)
            end)

            describe("when the actor is NOT in view", function()
                before_each(function()
                    stub(soundBite, "setAttributes")

                    subject.setLocation(cu.p3(20, 0, 1))
                    subject.updateAudio(fx)
                end)

                it("should have set correct pan and gain to 0.5", function()
                    assert.stub(soundBite.setAttributes).was_called_with(-1.0, 0.5)
                end)
            end)
        end)
    end)
end)
