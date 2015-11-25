require "lang.Signal"
require "specs.busted"

require "bridge.Bridge"
require "bridge.modules.ad"

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

    --[[
    context("when the user clicks the response", function()
        local c_response

        before_each(function()
            c_response = {id= request.getId(), state= AdState.Clicked}
            ad__callback(c_response)
        end)

        it("should have responded", function()
            assert.truthy(response.kindOf(AdResponse))
            assert.equal(response.getState(), AdState.Clicked)
        end)

        it("should no longer be tracking any requests", function()
            local requests = subject.getRequests()
            assert.equal(0, #requests)
        end)
    end)
    --]]
end)
