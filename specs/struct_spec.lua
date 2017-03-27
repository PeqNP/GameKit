require("lang.Signal")
require("specs.Cocos2d-x")
require("specs.busted")

-- TODO: All of the signal_spec class tests should be in this test.

describe("Struct", function()
    it("should create two different structs that do not conflict", function()
        local c0 = Struct()
        function c0.async()
            return "c0"
        end
        assert.equals(c0.async(), "c0")

        function c0.new(self)
            self.name = "c0"
        end
        local i0 = c0()
        assert.equals(i0.name, "c0")

        c1 = Struct()
        function c1.async()
            return "c1"
        end
        assert.equals(c1.async(), "c1")

        function c1.new(self)
            self.name = "c1"
        end
        local i1 = c1()
        assert.equals(i1.name, "c1")
    end)

    describe("when creating a new struct", function()
        local Test = false

        before_each(function()
            Test = Struct()
            function Test.new(self, x, y, z)
                self.x = x
                self.y = y
                self.z = z
            end
        end)

        it("should have provided all properties", function()
            local subject = Test(10, 20, 30)
            assert.equals(10, subject.x)
            assert.equals(20, subject.y)
            assert.equals(30, subject.z)
        end)
    end)
end)

