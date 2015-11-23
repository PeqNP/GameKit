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

    context("when sending successful request", function()
        local request
        local promise
        local response

        before_each(function()
            response = nil

            stub(adaptor, "send", true)

            request = TestRequest()
            response = subject.send("test", request, nil)
        end)

        it("should send the request to the adaptor", function()
            assert.stub(adaptor.send).was.called_with("test", message, nil)
        end)

        it("should have returned value from native layer", function()
            -- @todo
        end)
    end)

    context("when sending fails request", function()
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
end)
