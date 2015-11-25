require "lang.Signal"
require "specs.busted"

require "bridge.Bridge"
require "bridge.modules.ad"
require "ad.response.AdCacheResponse"
require "ad.response.AdCompleteResponse"

describe("modules.ad", function()
    local subject
    local bridge
    local payload
    local response

    before_each(function()
        payload = {}
        response = {}

        bridge = Bridge()
        mock(bridge, true)

        subject = require("bridge.modules.ad")
        subject.init(bridge)
    end)

    describe("register", function()
        local r

        before_each(function()
            stub(bridge, "send", response)
            r = subject.register(payload)
        end)

        it("should have sent correct request", function()
            assert.stub(bridge.send).was.called_with("ad__register", payload)
        end)

        it("should have returned the bridge's response", function()
            assert.equals(response, r)
        end)
    end)

    -- @todo cache
    -- @todo show
    -- @todo callback:cached
    -- @todo callback:completed

    describe("cache", function()
        local r

        before_each(function()
            stub(bridge, "sendAsync", response)
            r = subject.cache(payload)
        end)

        it("should have sent correct request", function()
            assert.stub(bridge.sendAsync).was.called_with("ad__cache", payload)
        end)

        it("should have returned the bridge's response", function()
            assert.equals(response, r)
        end)
    end)

    describe("show", function()
        local r

        before_each(function()
            stub(bridge, "sendAsync", response)
            r = subject.show(payload)
        end)

        it("should have sent correct request", function()
            assert.stub(bridge.sendAsync).was.called_with("ad__show", payload)
        end)

        it("should have returned the bridge's response", function()
            assert.equals(response, r)
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
                assert.equals(10, response.getId())
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
                assert.equals(10, response.getId())
                assert.truthy(response.isFailure())
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

            it("should have created a cached response", function()
                assert.truthy(response)
                assert.truthy(response.kindOf(AdCompleteResponse))
                assert.equals(10, response.getId())
                assert.falsy(response.isFailure())
                assert.equals(20, response.getReward())
                assert.truthy(response.isClicked())
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
                assert.equals(10, response.getId())
                assert.truthy(response.isFailure())
                assert.equals("An error", response.getError())
            end)
        end)
    end)
end)
