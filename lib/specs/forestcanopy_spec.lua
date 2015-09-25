
require "lang.Signal"

require "Logger"
Log.setLevel(LogLevel.Warning)

require "specs.Cocos2d-x"

require "Common"
require "game.Config"
require "game.actor.ForestCanopy"

describe("ForestCanopy", function()
    local subject = false

    before_each(function()
        subject = ForestCanopy()
    end)

    it("should have a default wind speed of 1", function()
        assert.equals(1, subject.getWindSpeed())
    end)

    it("should have default color", function()
        assert.truthy(subject.getSkyColor())
    end)

    describe("setWindSpeed", function()
        before_each(function()
            subject.setWindSpeed(2.0)
        end)

        it("should have a set wind speed to 2", function()
            assert.equals(2.0, subject.getWindSpeed())
        end)
    end)

    describe("setSkyColor", function()
        local color = false

        before_each(function()
            color = cc.c4b(0.5, 0.5, 0.5)
            subject.setSkyColor(color)
        end)

        it("should have a set wind speed to 2", function()
            assert.equals(color, subject.getSkyColor())
        end)
    end)

    describe("start", function()
        before_each(function()
            stub(subject.sprite, "scheduleUpdateWithPriorityLua")

            subject.start()
        end)

        it("should have scheduled itself to node", function()
            assert.stub(subject.sprite.scheduleUpdateWithPriorityLua).was.called()
        end)
    end)

    describe("stop", function()
        before_each(function()
            stub(subject.sprite, "unschedule")

            subject.stop()
        end)

        it("should have unscheduled itself from the node", function()
            assert.stub(subject.sprite.unschedule).was.called()
        end)
    end)
end)
