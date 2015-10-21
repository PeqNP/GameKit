require "lang.Signal"

-- @tood All of the signal_spec class tests should be in this test.

describe("Class", function()
    it("should create two different classes that do not conflict", function()
        local c0 = Class()
        function c0.async()
            return "c0"
        end
        assert.equals(c0.async(), "c0")

        function c0.new(self)
            self.name = "c0"
        end
        local i0 = c0()
        assert.equals(i0.name, "c0")

        c1 = Class()
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

    describe("when creating a new class", function()
        local Test = false

        before_each(function()
            Test = Class()
            function Test.new(self)
            end
        end)

        it("should return information about the class", function()
            assert.truthy(Test.getInfo())
        end)

        it("should be the same type of class", function()
            assert.truthy(Test.kindOf(Test))
        end)

        it("should not implement any protocols", function()
            local protocols = Test.getProtocols()
            assert.equal(0, #protocols)
        end)

        describe("when creating an instance of the Test class", function()
            local subject = false

            before_each(function()
                subject = Test()
            end)

            it("should be the Test class", function()
                assert.equals(Test, subject.getClass())
            end)

            it("should have the correct class name; the name of the file", function()
                assert.equals("class_spec", subject.getClassName())
            end)
        end)
    end)
end)
