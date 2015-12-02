require "lang.Signal"

require "ad.AdNetworkManager"

describe("AdNetworkManager", function()
    local subject
    local bridge
    local networks

    before_each(function()
        bridge = require("bridge.modules.ad")
        networks = require("specs.Mediation-test")
        subject = AdNetworkManager(bridge, networks)
    end)

    it("should have set the networks", function()
        assert.equals(networks, subject.getNetworks())
    end)

    describe("register", function()
        before_each(function()
            stub(bridge, "register")
            subject.registerNetworks()
        end)

        it("should have registered each of the networks", function()
            assert.stub(bridge.register).was.called()
        end)
    end)
end)
