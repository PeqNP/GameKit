require "lang.Signal"
require "specs.busted"

require "ad.Constants"

require "bridge.Bridge"
require "bridge.BridgeAdaptor"
require "bridge.BridgeRequest"

local id = 0
function get_id()
    id = id + 1
    return id
end

describe("Bridge", function()
    local subject
    local adaptor
    local TestRequest
    local message

    before_each(function()
        local fn = function() end
        adaptor = mock(BridgeAdaptor({}, "Controller", fn), true)
        subject = Bridge(adaptor)
        subject.registerModule("bridge.modules.ad")

        message = {}
        TestRequest = Class(BridgeRequest)
        function TestRequest.new(self)
            local id = get_id()
            function self.getId()
                return id
            end
            function self.toDict()
                return message
            end
        end

        TestResponse = Class()
        TestResponse.protocol(BridgeResponseProtocol)
        function TestResponse.new(self)
            local id
            function self.init(_id)
                id = _id
            end
            function self.getId()
                return id
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
        local request
        local promise
        local response

        before_each(function()
            response = nil

            stub(adaptor, "send", false)

            request = TestRequest()
            response = subject.send("test", request, nil)
        end)

        it("should have failed immediately", function()
            assert.falsy(response)
        end)
    end)

    context("when sending an async request", function()
        local request
        local call
        local nativeResponse
        local response

        before_each(function()
            nativeResponse = {}

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

        context("when the request fails", function()
            local t_response
            local p_response

            before_each(function()
                p_response = false
                call.done(function(r)
                    p_response = r
                end)
                t_response = TestResponse(request.getId())
                subject.receive(t_response)
            end)

            it("should have returned the response", function()
                assert.truthy(p_response)
                assert.equals(t_response, p_response)
            end)

            it("should no longer be tracking any requests", function()
                local requests = subject.getRequests()
                assert.equal(0, #requests)
            end)
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
    end)
end)
