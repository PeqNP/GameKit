require "lang.Signal"

require "ad.Constants"
require "ad.AdRequest"

describe("AdRequest", function()
    local subject

    before_each(function()
        subject = AdRequest()
    end)

    -- Start: These MUST be the first two tests! --
    it("should have created a new ID", function()
        assert.equal(1, subject.getId())
    end)

    it("should have created a new ID for second subject", function()
        assert.equal(2, subject.getId())
    end)
    -- End --

    it("should be in the initial state by default", function()
        assert.equal(AdState.Initial, subject.getState())
    end)

    describe("setState", function()
        before_each(function()
            subject.setState(AdState.Ready)
        end)

        it("should have set the state", function()
            assert.equal(AdState.Ready, subject.getState())
        end)
    end)
end)

