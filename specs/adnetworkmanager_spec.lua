require "lang.Signal"

require "ad.AdNetworkManager"

describe("AdNetworkManager", function()
    local subject
    local bridge
    local networks
    local adColony
    local adMob
    local leadbolt

    before_each(function()
        bridge = require("bridge.modules.ad")

        networks = require("specs.Mediation-test")
        adColony = networks[1]
        adMob = networks[2]
        leadbolt = networks[3]

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

        it("should have registered all networks", function()
            assert.stub(bridge.register).was.called_with(adColony)
            assert.stub(bridge.register).was.called_with(adMob)
            assert.stub(bridge.register).was.called_with(leadbolt)
        end)
    end)
end)
