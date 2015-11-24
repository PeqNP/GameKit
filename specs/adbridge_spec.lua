require "lang.Signal"
require "specs.busted"

xdescribe("modules.ad", function()
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
end)
