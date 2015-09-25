--[[ @todo Update the class to include Stereo Y but only if it
     it is a requested feature. ]]--

require "lang.Signal"

require "Logger"

require "specs.Cocos2d-x"

require "game.FXProcessor"

describe("FXProcessor", function()
    local subject

    -- @note This test assumes that the content size is 100,100.

    before_each(function()
        subject = FXProcessor(cc.size(50, 100))
    end)

    describe("when the point is at the left of the view", function()
        before_each(function()
            subject.setPoint(cc.p(0, 0))
        end)

        it("should be -1 when point is at the left edge", function()
            local pan, inView = subject.getPanForPoint(cc.p(0, 0))
            assert.equals(-1, pan)
            assert.truthy(inView)
        end)

        it("should be 1 when point is at the right edge", function()
            local pan, inView = subject.getPanForPoint(cc.p(100, 0))
            assert.equals(1, pan)
            assert.falsy(inView)
        end)

        it("should be 0 when in the center", function()
            local pan, inView = subject.getPanForPoint(cc.p(25, 0))
            assert.equals(0, pan)
            assert.truthy(inView)
        end)

        it("should be 1 and in view when on the right edge", function()
            local pan, inView = subject.getPanForPoint({x=50, y=0})
            assert.equals(1.0, pan)
            assert.truthy(inView)
        end)

        it("should be 1 and NOT in view", function()
            local pan, inView = subject.getPanForPoint({x=50.1, y=0})
            assert.equals(1.0, pan)
            assert.falsy(inView)
        end)
    end)

    describe("when the point is at the center of the view", function()
        before_each(function()
            subject.setPoint(cc.p(-25, 0))
        end)

        it("should have a left pan value", function()
            local pan, inView = subject.getPanForPoint({x=40, y=0})
            assert.equals(-0.4, pan)
            assert.truthy(inView)
        end)

        it("should have center pan value", function()
            local pan, inView = subject.getPanForPoint({x=50, y=0})
            assert.equals(0.0, pan)
            assert.truthy(inView)
        end)

        it("should have a right pan value", function()
            local pan, inView = subject.getPanForPoint({x=60, y=0})
            assert.equals(0.4, pan)
            assert.truthy(inView)
        end)
    end)

    describe("when the point is at the right of the view", function()
        before_each(function()
            subject.setPoint(cc.p(-50, 0))
        end)

        it("should be -1 and NOT in view", function()
            local pan, inView = subject.getPanForPoint({x=49.9, y=0})
            assert.equals(-1.0, pan)
            assert.falsy(inView)
        end)

        it("should be -1 and in view when on the left edge", function()
            local pan, inView = subject.getPanForPoint({x=50, y=0})
            assert.equals(-1.0, pan)
            assert.truthy(inView)
        end)

        it("should have a left pan value", function()
            local pan, inView = subject.getPanForPoint({x=65, y=0})
            assert.equals(-0.4, pan)
            assert.truthy(inView)
        end)

        it("should have center pan value", function()
            local pan, inView = subject.getPanForPoint({x=75, y=0})
            assert.equals(0.0, pan)
            assert.truthy(inView)
        end)

        it("should have a right pan value", function()
            local pan, inView = subject.getPanForPoint({x=85, y=0})
            assert.equals(0.4, pan)
            assert.truthy(inView)
        end)
    end)
end)
