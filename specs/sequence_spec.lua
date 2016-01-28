
require "lang.Signal"
require "specs.Cocos2d-x"

local shim = require("shim.Main")

describe("Sequence", function()
    local scene1
    local scene2
    local wasCalled1
    local wasCalled2
    local call1
    local call2

    before_each(function()
        wasCalled1 = false
        wasCalled2 = false
        call1 = shim.Call(function() wasCalled1 = true end)
        call2 = shim.Call(function() wasCalled2 = true end)
        scene1 = shim.Sequence("here", "there")
        scene2 = shim.Sequence(call1, "you", call2)
    end)

    it("should have set actions to scene1", function()
        local actions = scene1:getActions()
        assert.equals("here", actions[1])
        assert.equals("there", actions[2])
    end)

    it("should have set actions to scene2", function()
        local actions = scene2:getActions()
        assert.equals(call1, actions[1])
        assert.equals("you", actions[2])
        assert.equals(call2, actions[3])
    end)

    describe("execute the last call", function()
        before_each(function()
            scene2:executeLastCall()
        end)

        it("should have called the last Call", function()
            assert.is_true(wasCalled2)
        end)
    end)

    describe("execute all calls", function()
        before_each(function()
            scene2:executeCalls()
        end)

        it("should have called the last Call", function()
            assert.is_true(wasCalled1)
        end)

        it("should have called the last Call", function()
            assert.is_true(wasCalled2)
        end)
    end)
end)
