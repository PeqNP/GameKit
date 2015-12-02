
require "lang.Signal"
require "Error"


describe("Error", function()
    local subject

    describe("new", function()
        local info

        before_each(function()
            info = {myparams=1}
            subject = Error(1, "hi", info)
        end)

        it("should have set all the properties", function()
            assert.equals(1, subject.getCode())
            assert.equals("hi", subject.getMessage())
            assert.equals(info, subject.getInfo())
        end)
    end)
end)
