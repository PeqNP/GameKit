require "lang.Signal"
require "Music"

describe("Class", function()

    it("should create two different classes that do not conflict", function()
        local c0 = Class()
        function c0.async()
            return "c0"
        end
        assert.equals(c0.async(), "c0")

        function c0.new()
            local self = {}
            self.name = "c0"
            return self
        end
        local i0 = c0()
        assert.equals(i0.name, "c0")

        c1 = Class()
        function c1.async()
            return "c1"
        end
        assert.equals(c1.async(), "c1")

        function c1.new()
            local self = {}
            self.name = "c1"
            return self
        end
        local i1 = c1()
        assert.equals(i1.name, "c1")
    end)

    describe("when creating a new class", function()
        local Test = false

        before_each(function()
            Test = Class()
            function Test.new()
                return {}
            end
        end)

        it("should return the name of the class", function()
            assert.equals("class_spec", Test.getClass())
        end)

        describe("when creating an instance of the Test class", function()
            local test = false

            before_each(function()
                test = Test()
            end)

            it("should have the same class name as parent", function()
                assert.equals("class_spec", test.getClass())
            end)
        end)
    end)
end)
