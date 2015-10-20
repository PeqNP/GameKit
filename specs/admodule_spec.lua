require "lang.Signal"

require "ad.AdModule"

describe("AdModule", function()
    local subject

    before_each(function()
        subject = AdModule()
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
            assert.equal("AdRequest", request.getClass())
        end)
    end)
end)
