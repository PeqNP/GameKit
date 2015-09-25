
require "lang.Signal"

require "specs.Cocos2d-x"
require "specs.fixtures.Level"

require "Common"
require "Logger"
Log.setLevel(LogLevel.Error)

require "game.Config"
Singleton(Config, "/path")

require "game.TerraCycle"
require "game.AnimalGroup"
require "game.animal.Bird"

describe("AnimalGroup", function()
    local subject
    local actors
    local soundBites

    local actor1
    local actor2

    before_each(function()
        soundBites = {
            SoundBite(SoundType.Synchronous, LevelDepth.Near, "brid-near-%d.mp3", 1)
          , SoundBite(SoundType.Synchronous, LevelDepth.Near, "brid-far-%d.mp3", 1)
        }
        subject = AnimalGroup(Bird, soundBites)
        actors = subject.getActors()
        actor1 = actors[1]
        actor2 = actors[2]
    end)

    it("should have a reference to the class", function()
        assert.equals(Bird, subject.getActorClass())
    end)

    it("should have created 2 Birds", function()
        assert.equals(2, #actors)
        assert.equal("Bird", actor1.getClass())
        assert.equal("Bird", actor2.getClass())
    end)

    it("should have set respective SoundBite on both actors", function()
        assert.truthy(actor1.getSoundBite())
        assert.truthy(actor2.getSoundBite())
        assert.equals(soundBites[1], actor1.getSoundBite())
        assert.equals(soundBites[2], actor2.getSoundBite())
    end)

    it("should have set activeActorIndex to 1", function()
        assert.equals(1, subject.getActiveActorIndex())
    end)

    describe("nextCycle", function()
        local cycle = false
        local nextCycle = false

        before_each(function()
            stub(actor1, "nextCycle")
            stub(actor2, "nextCycle")
        end)

        describe("when the terra cycle is summer", function()
            before_each(function()
                cycle = TerraCycle(Season.Prevernal, DayCycle.Dawn, 0.0, 0.0)
                nextCycle = TerraCycle(Season.Prevernal, DayCycle.Morning, 0.0, 0.0)

                subject.nextCycle(cycle, nextCycle)
            end)

            it("should have called actor1.nextCycle", function()
                assert.stub(actor1.nextCycle).was.called_with(cycle, nextCycle)
            end)

            it("should have called actor2.nextCycle", function()
                assert.stub(actor2.nextCycle).was.called_with(cycle, nextCycle)
            end)

            it("should have set the active actor index back to 1", function()
                assert.equals(1, subject.getActiveActorIndex())
            end)
        end)

        describe("when the terra cycle is autumn", function()
            before_each(function()
                cycle = TerraCycle(Season.Autumnal, DayCycle.Dawn, 0.0, 0.0)
                nextCycle = TerraCycle(Season.Autumnal, DayCycle.Morning, 0.0, 0.0)

                subject.nextCycle(cycle, nextCycle)
            end)

            it("should have called actor1.nextCycle", function()
                assert.stub(actor1.nextCycle).was.called_with(cycle, nextCycle)
            end)

            it("should not have called actor2.nextCycle", function()
                assert.stub(actor2.nextCycle).was.not_called()
            end)

            it("should have set the active actor index to 2 (the next actor)", function()
                assert.equals(2, subject.getActiveActorIndex())
            end)
        end)

        describe("when the terra cycle is winter", function()
            before_each(function()
                cycle = TerraCycle(Season.Hibernal, DayCycle.Dawn, 0.0, 0.0)
                nextCycle = TerraCycle(Season.Hibernal, DayCycle.Morning, 0.0, 0.0)

                subject.nextCycle(cycle, nextCycle)
            end)

            it("should have called actor1.nextCycle", function()
                assert.stub(actor1.nextCycle).was.not_called()
            end)

            it("should not have called actor2.nextCycle", function()
                assert.stub(actor2.nextCycle).was.not_called()
            end)

            it("should have stayed at 1", function()
                assert.equals(1, subject.getActiveActorIndex())
            end)
        end)
    end)

    describe("start", function()
        local level

        before_each(function()
            stub(actor1, "start")
            stub(actor2, "start")

            level = Level1()
            subject.start(level)
        end)

        it("should have called actor1.nextCycle", function()
            assert.stub(actor1.start).was.called_with(level)
        end)

        it("should have called actor2.nextCycle", function()
            assert.stub(actor2.start).was.called_with(level)
        end)

        it("should have set the actor group level", function()
            assert.equals(level, subject.getLevel())
        end)

        describe("stop", function()
            before_each(function()
                stub(actor1, "stop")
                stub(actor2, "stop")

                subject.stop()
            end)

            it("should have called actor1.nextCycle", function()
                assert.stub(actor1.stop).was.called()
            end)

            it("should have called actor2.nextCycle", function()
                assert.stub(actor2.stop).was.called()
            end)

            it("should have set the level to nil", function()
                assert.falsy(subject.getLevel())
            end)
        end)
    end)

    describe("when stopping when actor has not yet started", function()
    end)
end)
