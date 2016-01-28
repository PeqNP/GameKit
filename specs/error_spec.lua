
require "lang.Signal"
local Error = require("Error")

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

        it("should emit formatted error", function()
            assert.equal("Code (1) Message (hi)", tostring(subject))
            --assert.equal("Code (1) Message (hi) Info (myparams=1)", tostring(subject))
        end)
    end)
end)
