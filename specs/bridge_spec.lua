require "lang.Signal"
require "specs.busted"

require "ad.Constants"

require "bridge.Bridge"
require "bridge.BridgeAdaptor"
require "bridge.BridgeRequest"

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
            function self.getMessage()
                return message
            end
        end
    end)

    it("should return the adaptor", function()
        assert.equal(adaptor, subject.getAdaptor())
    end)

    it("should have loaded the module", function()
        assert.truthy(ad__callback)
    end)

    it("should have the module", function()
        local modules = subject.getModules()
        assert.equal(1, #modules)
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

    describe("send", function()
        local request
        local promise
        local response

        before_each(function()
            response = nil

            stub(adaptor, "send")

            request = TestRequest()
            promise = subject.send("test", request)
            promise.done(function(r)
                response = r
            end)
        end)

        it("should send the request to the adaptor", function()
            assert.stub(adaptor.send).was.called_with("test", message)
        end)

        it("should not yet have responded", function()
            assert.falsy(response)
        end)

        xcontext("when the user clicks the response", function()
            local c_response

            before_each(function()
                c_response = {id= request.getId(), state= AdState.Clicked}
                ad__callback(c_response)
            end)

            it("should have responded", function()
                assert.truthy(response)
                assert.equal(c_response, response)
            end)
        end)
    end)
end)
