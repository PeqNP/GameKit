require "lang.Signal"
require "specs.busted"

require "bridge.Bridge"
require "bridge.modules.ad"
require "ad.response.AdCacheResponse"
require "ad.response.AdCompleteResponse"
require "ad.Ad"
require "ad.networks.AdColonyNetwork"

local match = require("luassert.match")

describe("modules.ad", function()
    local subject
    local bridge
    local call
    local network
    local payload
    local response

    before_each(function()
        payload = {}
        network = AdColonyNetwork("id", {Ad()})
        stub(network, "getConfig", payload)

        response = {}

        bridge = Bridge()
        mock(bridge, true)
        call = BridgeCall()
        mock(call, true)

        subject = require("bridge.modules.ad")
        subject.init(bridge)
    end)

    context("successful register", function()
        local r

        before_each(function()
            response = {success=true, tokens={1, 2}}
            stub(bridge, "send", response)
            r = subject.register(network)
        end)

        it("should have sent correct request", function()
            assert.stub(bridge.send).was.called_with("ad__register", payload)
        end)

        it("should have returned a registered response", function()
            assert.truthy(r.kindOf(AdRegisterResponse))
        end)

        it("should be a successful response", function()
            assert.truthy(r.isSuccess())
        end)

        it("should have created two tokens", function()
            local tokens = r.getTokens()
            assert.equals(2, #tokens)
        end)

        it("should have created ad token 1 correctly", function()
            local tokens = r.getTokens()
            local token = tokens[1]
            assert.equals(1, token)
        end)

        it("should have created ad token 2 correctly", function()
            local tokens = r.getTokens()
            local token = tokens[2]
            assert.equals(2, token)
        end)
    end)

    context("failed register", function()
        before_each(function()
            response = {success=false, error="An error"}
            stub(bridge, "send", response)
            r = subject.register(network)
        end)

        it("should have sent correct request", function()
            assert.stub(bridge.send).was.called_with("ad__register", payload)
        end)

        it("should have returned a registered response", function()
            assert.equals(AdRegisterResponse, r.getClass())
        end)

        it("should not be a successful response", function()
            assert.falsy(r.isSuccess())
        end)

        it("should not have created any tokens", function()
            local tokens = r.getTokens()
            assert.equals(0, #tokens)
        end)

        it("should have an error", function()
            assert.equals("An error", r.getError())
        end)
    end)

    describe("cache", function()
        local r
        local c

        before_each(function()
            response = {success=true}
            stub(bridge, "sendAsync", response, call)
            r, c = subject.cache(1)
        end)

        it("should have sent correct request", function()
            assert.stub(bridge.sendAsync).was.called_with("ad__cache", match._)
        end)

        it("should have returned the BridgeCall", function()
            assert.equals(call, c)
        end)

        it("should have returned the bridge's response", function()
            assert.equals(AdResponse, r.getClass())
        end)

        it("should be a success", function()
            assert.truthy(r.isSuccess())
        end)
    end)

    describe("failed cache", function()
        local r
        local c

        before_each(function()
            response = {success=false, error="An error"}
            stub(bridge, "sendAsync", response, call)
            r, c = subject.cache(2)
        end)

        it("should have sent correct request", function()
            assert.stub(bridge.sendAsync).was.called_with("ad__cache", match._)
        end)

        it("should have returned the BridgeCall", function()
            assert.equals(call, c)
        end)

        it("should have returned the bridge's response", function()
            assert.equals(AdResponse, r.getClass())
        end)

        it("should be a failure", function()
            assert.falsy(r.isSuccess())
        end)

        it("should have set correct error on response", function()
            assert.equals("An error", r.getError())
        end)
    end)

    describe("show", function()
        local r
        local c

        before_each(function()
            response = {success=true}
            stub(bridge, "sendAsync", response, call)
            r, c = subject.show(3)
        end)

        it("should have sent correct request", function()
            assert.stub(bridge.sendAsync).was.called_with("ad__show", match._)
        end)

        it("should have returned the BridgeCall", function()
            assert.equals(call, c)
        end)

        it("should have returned the bridge's response", function()
            assert.equals(AdResponse, r.getClass())
        end)

        it("should be a successful response", function()
            assert.truthy(r.isSuccess())
        end)
    end)

    describe("failed show", function()
        local r
        local c

        before_each(function()
            response = {success=false, error="An error"}
            stub(bridge, "sendAsync", response, call)
            r, c = subject.show(4)
        end)

        it("should have returned the BridgeCall", function()
            assert.equals(call, c)
        end)

        it("should have sent correct request", function()
            assert.stub(bridge.sendAsync).was.called_with("ad__show", match._)
        end)

        it("should have returned the bridge's response", function()
            assert.equals(AdResponse, r.getClass())
        end)

        it("should be a failure", function()
            assert.falsy(r.isSuccess())
        end)

        it("should have set correct error on response", function()
            assert.equals("An error", r.getError())
        end)
    end)

    context("when an ad is cached", function()
        local subject
        local c_response
        local response
        local bridge

        before_each(function()
            response = nil

            bridge = Bridge()
            bridge.receive = function(r)
                response = r
            end

            subject = require("bridge.modules.ad")
            subject.init(bridge)
        end)

        context("when caching is successful", function()
            before_each(function()
                c_response = {token= 10}
                ad__cached(c_response)
            end)

            it("should have created a cached response", function()
                assert.truthy(response)
                assert.truthy(response.kindOf(AdCacheResponse))
            end)

            it("should have set the correct ID", function()
                assert.equals(10, response.getId())
            end)

            it("should not have an error", function()
                assert.falsy(response.isFailure())
            end)
        end)

        context("when caching is unsuccessful", function()
            before_each(function()
                c_response = {token= 10, error="An error"}
                ad__cached(c_response)
            end)

            it("should have created a cached response", function()
                assert.truthy(response)
                assert.truthy(response.kindOf(AdCacheResponse))
            end)

            it("should have set the correct ID", function()
                assert.equals(10, response.getId())
            end)

            it("should have an error", function()
                assert.truthy(response.isFailure())
            end)

            it("should have set the error", function()
                assert.equals("An error", response.getError())
            end)
        end)
    end)

    context("when an ad is shown", function()
        local subject
        local c_response
        local response
        local bridge

        before_each(function()
            response = nil

            bridge = Bridge()
            bridge.receive = function(r)
                response = r
            end

            subject = require("bridge.modules.ad")
            subject.init(bridge)
        end)

        context("when showing is successful", function()
            before_each(function()
                c_response = {token= 10, reward=20, clicked=true}
                ad__completed(c_response)
            end)

            it("should have created a completed response", function()
                assert.truthy(response)
                assert.truthy(response.kindOf(AdCompleteResponse))
            end)

            it("should have set the correct ID", function()
                assert.equals(10, response.getId())
            end)

            it("should have set correct reward", function()
                assert.equals(20, response.getReward())
            end)

            it("should be clicked", function()
                assert.truthy(response.isClicked())
            end)

            it("should not have an error", function()
                assert.falsy(response.isFailure())
            end)
        end)

        context("when caching is unsuccessful", function()
            before_each(function()
                c_response = {token= 10, error="An error"}
                ad__completed(c_response)
            end)

            it("should have created a completed response", function()
                assert.truthy(response)
                assert.truthy(response.kindOf(AdCompleteResponse))
            end)

            it("should have set the correct ID", function()
                assert.equals(10, response.getId())
            end)

            it("should have an error", function()
                assert.truthy(response.isFailure())
                assert.equals("An error", response.getError())
            end)
        end)
    end)
end)
