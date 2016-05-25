require "lang.Signal"
require "specs.busted"
require "Logger"

Log.setLevel(LogLevel.Warning)

require "bridge.modules.social"
local Bridge = require("bridge.Bridge")
local BridgeCall = require("bridge.BridgeCall")
local BridgeResponse = require("bridge.BridgeResponse")
local PostResponse = require("social.PostResponse")

describe("bridge.modules.social Send", function()
    local subject
    local bridge

    before_each(function()
        request = {}
        response = {}

        bridge = Bridge()
        mock(bridge, true)
        call = BridgeCall()
        mock(call, true)

        subject = require("bridge.modules.social")
        subject.init(bridge)
    end)

    describe("post", function()
        local request
        local response

        before_each(function()
            request = nil
        end)

        context("when the process succeeds", function()
        end)

        context("when the process fails", function()
        end)
    end)
end)

describe("bridges.modules.social Receive", function()
    local subject
    local bridge
    local response

    before_each(function()
        response = nil

        bridge = Bridge()
        bridge.receive = function(r)
            response = r
        end

        subject = require("bridge.modules.social")
        subject.init(bridge)
    end)

    describe("completed post", function()
        local json

        before_each(function()
            json = "{\"id\": 4, \"success\": true, \"code\": 1, \"error\": \"An error!\"}"
            social__completed(json)
        end)

        it("should have sent message to bridge that a transaction was completed", function()
            assert.truthy(response)
            assert.equal(PostResponse, response.getClass())
        end)

        it("should have set the correct values", function()
            assert.equal(4, response.getId())
            assert.equal(true, response.isSuccess())
            assert.equal(1, response.getCode())
            assert.equal("An error!", response.getError())
        end)
    end)
end)
