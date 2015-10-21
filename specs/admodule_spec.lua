require "lang.Signal"

require "ad.modules.AdMobInterstitial"

describe("AdModule", function()
    local subject

    before_each(function()
        subject = AdMobInterstitial()
    end)

    describe("generate a request", function()
        local request

        before_each(function()
            request = subject.generateAdRequest()
        end)

        it("should not have changed the state of the request", function()
            assert.equal(AdState.Initial, request.getState())
        end)

        it("should have created a new ad request", function()
            assert.truthy(request.kindOf(AdRequest))
        end)
    end)
end)
