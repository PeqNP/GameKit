require("specs.busted")
require("specs.Cocos2d-x")
require("lang.Signal")
require("Logger")

Log.setLevel(LogLevel.Warning)

local BridgeCall = require("bridge.BridgeCall")
local BridgeResponse = require("bridge.BridgeResponse")
local Error = require("Error")
local Manager = require("social.Manager")
local Network = require("social.Network")
local PostRequest = require("social.PostRequest")
local PostResponse = require("social.PostResponse")

require("specs.helpers")
local match = require("specs.matchers")

describe("social.Manager", function()
    local subject
    local bridge

    before_each(function()
        bridge = require("bridge.modules.social")
        subject = Manager(bridge)
    end)

    describe("configure network", function()
        context("when configuring succeeds", function()
            local response
            local network
            local request

            before_each(function()
                request = nil
                function bridge.configure(r)
                    request = r
                    return BridgeResponse(true, 5)
                end

                network = Network("Twitter", {appkeya="1234", secret="itsasecret"})
                response = subject.configure(network)
            end)

            it("should have called configure with correct parameters", function()
                assert.truthy(request)
                local dict = request.toDict()
                assert.equal("Twitter", dict.service)
                assert.equal(network.getConfig(), dict.config)
            end)

            it("should be successfull", function()
                assert.truthy(response)
            end)
        end)

        context("when configuring fails", function()
            local response
            local _error

            before_each(function()
                stub(bridge, "configure", BridgeResponse(false, 5, "An error message", info))
                response, _error = subject.configure(Network("Twitter", {appkey="1234", secret="itsasecret"}))
            end)

            it("should fail", function()
                assert.falsy(response)
            end)

            it("should return an error", function()
                assert.equal(1, _error.getCode())
                assert.equal("An error message", _error.getMessage())
            end)
        end)
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

