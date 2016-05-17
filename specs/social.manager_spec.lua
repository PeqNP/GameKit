require "specs.busted"
require "specs.Cocos2d-x"
require "lang.Signal"

local BridgeCall = require("bridge.BridgeCall")
local BridgeResponse = require("bridge.BridgeResponse")
local Manager = require("social.Manager")
local PostRequest = require("social.PostRequest")
local PostResponse = require("social.PostResponse")

require("specs.helpers")
local match = require("specs.matchers")

describe("iap.Social", function()
    local subject
    local bridge

    before_each(function()
        bridge = require("bridge.modules.social")
        subject = Manager(bridge)
    end)

    describe("post a message", function()
        local response
        local promise
        local success
        local _error

        before_each(function()
            success = false

            call = BridgeCall()
            stub(bridge, "post", BridgeResponse(true, 10), call)

            promise = subject.post("Twitter", "A message to post", "/path/to/image.png", true)
            promise.done(function()
                success = true
            end)
            promise.fail(function(_e)
                _error = _e
            end)
        end)

        context("when the response is successful", function()
            before_each(function()
                call.resolve(PostResponse(10, true))
            end)

            it("should be successfull", function()
                assert.truthy(success)
            end)
        end)

        context("when the response is successful but has error", function()
            before_each(function()
                call.resolve(PostResponse(10, false, 50, "An error"))
            end)

            it("should NOT be successfull", function()
                assert.falsy(success)
            end)

            it("should reject and return an error", function()
                assert.equal(50, _error.getCode())
                assert.equal("An error", _error.getMessage())
            end)
        end)

        context("when the response fails", function()
            before_each(function()
                call.reject()
            end)

            it("should return error", function()
                assert.equal(2, _error.getCode())
                assert.equal("Unknown error occurred.", _error.getMessage())
            end)
        end)
    end)
end)

