require "lang.Signal"
require "specs.busted"
require "Logger"

Log.setLevel(LogLevel.Warning)

require "bridge.Bridge"
require "bridge.modules.ad"
require "ad.response.AdCompleteResponse"
require "ad.networks.AdColonyNetwork"

local match = require("luassert.match")

local function is_equal(state, arguments)
    local expected = arguments[1]
    return function(value)
        return table.equals(expected, value)
    end
end

assert:register("matcher", "equal", is_equal)

Ad = Class()
function Ad.new(self)
    local adId
    function self.init(_adId)
        adId = _adId
    end
    function self.getAdId()
        return adId
    end
    function self.setAdNetwork(network)
    end
end

describe("modules.ad", function()
    local subject
    local bridge
    local call
    local request -- id<AdRegisterNetworkRequest>
    local response

    before_each(function()
        request = {}
        response = {}

        bridge = Bridge()
        mock(bridge, true)
        call = BridgeCall()
        mock(call, true)

        subject = require("bridge.modules.ad")
        subject.init(bridge)
    end)

    describe("configuring the ad service", function()
        context("when successful", function()
            local r

            before_each(function()
                response = {success=true}
                stub(bridge, "send", response)
                r = subject.configure(request)
            end)

            it("should have sent the config", function()
                assert.stub(bridge.send).was.called_with("ad__configure", request)
            end)

            it("should have returned an BridgeResponse", function()
                assert.equal(BridgeResponse, r.getClass())
            end)

            it("should have set properties correctly", function()
                assert.truthy(r.isSuccess())
                assert.falsy(r.getError())
            end)
        end)

        context("when failure", function()
            local r

            before_each(function()
                response = {success=false, error="Error happened"}
                stub(bridge, "send", response)
                r = subject.configure(request)
            end)

            it("should have sent the config", function()
                assert.stub(bridge.send).was.called_with("ad__configure", request)
            end)

            it("should have returned an BridgeResponse", function()
                assert.equal(BridgeResponse, r.getClass())
            end)

            it("should have set properties correctly", function()
                assert.falsy(r.isSuccess())
                assert.equal("Error happened", r.getError())
            end)
        end)
    end)

    context("successful register", function()
        local r

        before_each(function()
            response = {success=true, adids="1,2"}
            stub(bridge, "send", response)
            r = subject.register(request)
        end)

        it("should have sent correct request", function()
            assert.stub(bridge.send).was.called_with("ad__register", request)
        end)

        it("should have returned a registered response", function()
            assert.truthy(r.kindOf(AdRegisterNetworkResponse))
        end)

        it("should be a successful response", function()
            assert.truthy(r.isSuccess())
        end)

        it("should have created two ad IDs", function()
            local adIds = r.getAdIds()
            assert.equals(2, #adIds)
        end)

        it("should have created ad ID 1 correctly", function()
            local adIds = r.getAdIds()
            local adId = adIds[1]
            assert.equals(1, adId)
        end)

        it("should have created ad ID 2 correctly", function()
            local adIds = r.getAdIds()
            local adId = adIds[2]
            assert.equals(2, adId)
        end)
    end)

    context("failed register", function()
        before_each(function()
            response = {success=false, error="An error"}
            stub(bridge, "send", response)
            r = subject.register(request)
        end)

        it("should have sent correct request", function()
            assert.stub(bridge.send).was.called_with("ad__register", request)
        end)

        it("should have returned a registered response", function()
            assert.equals(AdRegisterNetworkResponse, r.getClass())
        end)

        it("should not be a successful response", function()
            assert.falsy(r.isSuccess())
        end)

        it("should not have created any ad IDs", function()
            local adIds = r.getAdIds()
            assert.equals(0, #adIds)
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
            r, c = subject.cache(request)
        end)

        it("should have sent correct request", function()
            assert.stub(bridge.sendAsync).was.called_with("ad__cache", request)
        end)

        it("should have returned the BridgeCall", function()
            assert.equals(call, c)
        end)

        it("should have returned the bridge's response", function()
            assert.equals(BridgeResponse, r.getClass())
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
            r, c = subject.cache(request)
        end)

        it("should have sent correct request", function()
            assert.stub(bridge.sendAsync).was.called_with("ad__cache", request)
        end)

        it("should have returned the BridgeCall", function()
            assert.equals(call, c)
        end)

        it("should have returned the bridge's response", function()
            assert.equals(BridgeResponse, r.getClass())
        end)

        it("should be a failure", function()
            assert.falsy(r.isSuccess())
        end)

        it("should have set correct error on response", function()
            assert.equals("An error", r.getError())
        end)
    end)

    describe("exception cache", function()
        local r
        local c

        before_each(function()
            response = -1
            stub(bridge, "sendAsync", response, call)
            r, c = subject.cache(request)
        end)

        it("should have returned the BridgeCall", function()
            assert.equals(call, c)
        end)

        it("should have returned the bridge's response", function()
            assert.equals(BridgeResponse, r.getClass())
        end)

        it("should be a failure", function()
            assert.falsy(r.isSuccess())
        end)

        it("should have set error on response", function()
            assert.equals("Failed to cache ad", r.getError())
        end)
    end)

    describe("show", function()
        local r
        local c

        before_each(function()
            response = {success=true, id=23}
            stub(bridge, "sendAsync", response, call)
            r, c = subject.show(request)
        end)

        it("should have sent correct request", function()
            assert.stub(bridge.sendAsync).was.called_with("ad__show", request)
        end)

        it("should have returned the BridgeCall", function()
            assert.equals(call, c)
        end)

        it("should have returned the bridge's response", function()
            assert.equals(BridgeResponse, r.getClass())
        end)

        it("should be a successful response", function()
            assert.truthy(r.isSuccess())
        end)

        it("should have set the ID on the response", function()
            assert.equal(23, r.getId())
        end)
    end)

    describe("failed show", function()
        local r
        local c

        before_each(function()
            response = {success=false, error="An error"}
            stub(bridge, "sendAsync", response, call)
            r, c = subject.show(request)
        end)

        it("should have returned the BridgeCall", function()
            assert.equals(call, c)
        end)

        it("should have sent correct request", function()
            assert.stub(bridge.sendAsync).was.called_with("ad__show", request)
        end)

        it("should have returned the bridge's response", function()
            assert.equals(BridgeResponse, r.getClass())
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
                c_response = "{\"success\": true, \"id\": 54, \"reward\": 66}"
                ad__cached(c_response)
            end)

            it("should have created a cached response", function()
                assert.truthy(response)
                assert.truthy(response.kindOf(AdCacheResponse))
            end)

            it("should have set the correct ID", function()
                assert.equals(54, response.getId())
            end)

            it("should have set the correct reward", function()
                assert.equal(66, response.getReward())
            end)

            it("should not have an error", function()
                assert.truthy(response.isSuccess())
            end)
        end)

        context("when caching is unsuccessful", function()
            before_each(function()
                c_response = "{\"success\": false, \"id\": 10, \"error\": \"An error\"}"
                ad__cached(c_response)
            end)

            it("should have created a cached response", function()
                assert.truthy(response)
                assert.truthy(response.kindOf(BridgeResponse))
            end)

            it("should have set the correct ID", function()
                assert.equals(10, response.getId())
            end)

            it("should not have set the reward", function()
                assert.falsy(response.getReward())
            end)

            it("should have an error", function()
                assert.falsy(response.isSuccess())
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
                c_response = "{\"success\": true, \"id\": 11, \"reward\": 20, \"clicked\": true}"
                ad__completed(c_response)
            end)

            it("should have created a completed response", function()
                assert.truthy(response)
                assert.truthy(response.kindOf(AdCompleteResponse))
            end)

            it("should have set the correct ID", function()
                assert.equals(11, response.getId())
            end)

            it("should have set correct reward", function()
                assert.equals(20, response.getReward())
            end)

            it("should be clicked", function()
                assert.truthy(response.isClicked())
            end)

            it("should not have an error", function()
                assert.truthy(response.isSuccess())
            end)
        end)

        context("when caching is unsuccessful", function()
            before_each(function()
                c_response = "{\"success\": false, \"id\": 21, \"error\": \"An error\"}"
                ad__completed(c_response)
            end)

            it("should have created a completed response", function()
                assert.truthy(response)
                assert.truthy(response.kindOf(AdCompleteResponse))
            end)

            it("should have set the correct ID", function()
                assert.equals(21, response.getId())
            end)

            it("should have an error", function()
                assert.falsy(response.isSuccess())
                assert.equals("An error", response.getError())
            end)
        end)
    end)

    context("when hiding the banner ad", function()
        local r

        before_each(function()
            stub(bridge, "send", {success=true, error="Error"})
            r = subject.hideBannerAd()
        end)

        it("should have made call to bridge to hide banner ad", function()
            assert.stub(bridge.send).was.called_with("ad__hideBanner")
        end)

        it("should have returned response", function()
            assert.equal(BridgeResponse, r.getClass())
        end)

        it("should have set properties on BridgeResponse", function()
            assert.truthy(r.isSuccess())
            assert.equal("Error", r.getError())
        end)
    end)
end)
