require "lang.Signal"
require "specs.busted"
require "Logger"

Log.setLevel(LogLevel.Severe)

require "ad.Constants"

local Bridge = require("bridge.Bridge")
local BridgeCall = require("bridge.BridgeCall")
local BridgeResponse = require("bridge.BridgeResponse")
local BridgeAdaptorProtocol = require("bridge.BridgeAdaptorProtocol")
local BridgeRequestProtocol = require("bridge.BridgeRequestProtocol")

describe("Bridge", function()
    local subject
    local adaptor
    local TestRequest
    local message

    before_each(function()
        adaptor = mock(mock_protocol(BridgeAdaptorProtocol), true)
        subject = Bridge(adaptor)
        subject.registerModule("bridge.modules.ad")

        message = {}
        TestRequest = Class()
        TestRequest.implements(BridgeRequestProtocol)
        function TestRequest.new(self)
            function self.toDict()
                return message
            end
        end
    end)

    it("should return the adaptor", function()
        assert.equal(adaptor, subject.getAdaptor())
    end)

    it("should have loaded the module", function()
        assert.truthy(ad__cached)
        assert.truthy(ad__completed)
    end)

    it("should have the module", function()
        local modules = subject.getModules()
        assert.equal(1, #modules)
    end)

    it("should have no requests", function()
        local requests = subject.getRequests()
        assert.equal(0, #requests)
    end)

    context("when registering the same module again", function()
        before_each(function()
            subject.registerModule("bridge.modules.ad")
        end)

        it("should not have loaded it twice", function()
            local modules = subject.getModules()
            assert.equal(1, #modules)
        end)
    end)

    context("when sending a request", function()
        local request
        local promise
        local response
        local nativeResponse

        before_each(function()
            nativeResponse = {}

            stub(adaptor, "send", nativeResponse)

            request = TestRequest()
            response = subject.send("test", request, nil)
        end)

        it("should send the request to the adaptor", function()
            assert.stub(adaptor.send).was.called_with("test", message, nil)
        end)

        it("should have returned value from native layer", function()
            assert.equals(nativeResponse, response)
        end)
    end)

    context("when sending a request failed", function()
        local response

        before_each(function()
            stub(adaptor, "send", false)

            local request = TestRequest()
            response = subject.send("test", request, nil)
        end)

        it("should have failed immediately", function()
            assert.falsy(response)
        end)
    end)

    context("when sending a request w/ no parameters", function()
        local response
        local nativeResponse

        before_each(function()
            nativeResponse = {}
            stub(adaptor, "send", nativeResponse)
            response = subject.send("method")
        end)

        it("should succeed", function()
            assert.equal(nativeResponse, response)
        end)

        it("should have called the adaptor with correct parameters", function()
            assert.stub(adaptor.send).was.called_with("method", nil, nil)
        end)
    end)

    context("when sending an async request", function()
        local request
        local call
        local nativeResponse
        local response

        -- TODO: Test when native response is false and not just true w/ ID.
        before_each(function()
            nativeResponse = {success=true, id=54}

            stub(adaptor, "send", nativeResponse)

            request = TestRequest()
            response, call = subject.sendAsync("test", request, nil)
        end)

        it("should send the request to the adaptor", function()
            assert.stub(adaptor.send).was.called_with("test", message, nil)
        end)

        it("should have returned value from native layer", function()
            assert.equals(nativeResponse, response)
        end)

        it("should have returned the correct call", function()
            assert.equal(BridgeCall, call.getClass())
            assert.equal(request, call.getRequest())
        end)

        it("should be tracking the request", function()
            local requests = subject.getRequests()
            assert.equal(call, requests["54"])
            assert.equal(1, subject.getNumRequests())
        end)

        context("when the async request is received", function()
            local t_response
            local p_response
            local e_response

            before_each(function()
                p_response = false
                call.done(function(r)
                    p_response = r
                end)
                call.fail(function(e)
                    e_response = e
                end)
                t_response = BridgeResponse(true, 54)
                subject.receive(t_response)
            end)

            it("should have resolved request w/ response", function()
                assert.falsy(e_response)
                assert.truthy(p_response)
                assert.equals(t_response, p_response)
            end)

            it("should no longer be tracking any requests", function()
                local requests = subject.getRequests()
                assert.equal(0, #requests)
            end)
        end)

        context("when the async request succeeds", function()
            local t_response
            local p_response
            local e_response

            before_each(function()
                p_response = false
                call.done(function(r)
                    p_response = r
                end)
                call.fail(function(e)
                    e_response = e
                end)
                t_response = BridgeResponse(false, 54)
                subject.receive(t_response)
            end)

            it("should have rejected the request w/ the response", function()
                assert.falsy(p_response)
                assert.truthy(e_response)
                assert.equals(t_response, e_response)
            end)

            it("should no longer be tracking any requests", function()
                local requests = subject.getRequests()
                assert.equal(0, #requests)
            end)
        end)

        context("when a non-existant async request is received", function()
            local t_response
            local p_response

            before_each(function()
                p_response = false
                call.done(function(r)
                    p_response = r
                end)
                t_response = BridgeResponse(true, 21)
                subject.receive(t_response)
            end)

            it("should NOT have completed the existing request", function()
                assert.falsy(p_response)
            end)

            it("should still be tracking our existing request", function()
                assert.equal(1, subject.getNumRequests())
            end)
        end)
    end)

    context("when sending an async request with no parameters", function()
        local call
        local nativeResponse
        local response

        -- TODO: Test when native response is false and not just true w/ ID.
        before_each(function()
            nativeResponse = {success=true}

            stub(adaptor, "send", nativeResponse)

            response, call = subject.sendAsync("test")
        end)

        it("should send the request to the adaptor", function()
            assert.stub(adaptor.send).was.called_with("test")
        end)
    end)

    context("when async requests success is false", function()
        local request
        local call
        local nativeResponse
        local response
        local _error

        before_each(function()
            nativeResponse = {success=false, error="My failure"}

            stub(adaptor, "send", nativeResponse)

            request = TestRequest()
            response, call = subject.sendAsync("test", request, nil)
            call.fail(function(e)
                _error = e
            end)
        end)

        it("should have returned the correct values", function()
            assert.equal(nativeResponse, response)
            assert.equal(BridgeCall, call.getClass())
        end)

        it("should NOT have tracked the request", function()
            assert.equal(0, subject.getNumRequests())
        end)

        it("should have rejected immediately", function()
            assert.equals("My failure", _error)
        end)
    end)

    context("when async request fails", function()
        local request
        local call
        local _error
        local response

        before_each(function()
            _error = nil
            response = true

            stub(adaptor, "send", false)

            request = TestRequest()
            response, call = subject.sendAsync("test", request, nil)
            call.fail(function(e)
                _error = e
            end)
        end)

        it("should have rejected immediately", function()
            assert.equals("Failed to call method (test)", _error)
        end)

        it("should have returned native response", function()
            assert.falsy(response)
        end)

        it("should not have tracked the request", function()
            assert.equal(0, subject.getNumRequests())
        end)
    end)
end)
