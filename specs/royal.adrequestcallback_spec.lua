require "lang.Signal"
require "specs.Cocos2d-x"
require "Logger"

local AdRequestCallback = require("royal.AdRequestCallback")

describe("AdRequestCallback", function()
    local subject

    local callback
    local file
    local request

    local wasCalled -- callback vars
    local f
    local r

    before_each(function()
        wasCalled = false
        callback = function(_f, _r) wasCalled = true; f = _f; r = _r end
        file = "/path/"
        request = {}
        subject = AdRequestCallback(callback, file, request)
    end)

    describe("execute", function()
        before_each(function()
            subject.execute()
        end)

        it("should have called the callback with correct parameters", function()
            assert.truthy(wasCalled)
            assert.equals(file, f)
            assert.equals(request, r)
        end)
    end)
end)
