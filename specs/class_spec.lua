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

Satan = Class()
function Satan.new(self)
end

God = Class()
function God.new(self, a, b)
    function self.getA()
        return a
    end

    function self.getB()
        return b
    end
end

Parent = Class(God)
function Parent.new(self)
end

Child = Class(Parent)
function Child.new(self)
end

describe("Class methods", function()
    local god

    before_each(function()
        god = God(1, 2)
    end)

    it("should have passed through the parameters", function()
        assert.equal(1, god.getA())
        assert.equal(2, god.getB())
    end)

    it("should not conform to any protocols", function()
        assert.equal(0, #God.getProtocols())
    end)

    it("should return the correct class", function()
        assert.equal(God, god.getClass())
    end)

    it("should return the class name; the name of this file w/o the extension", function()
        assert.equal("class_spec", god.getClassName())
    end)

    it("should be kind of self", function()
        assert.truthy(god.kindOf(God))
    end)
end)

describe("Subclassing", function()
    describe("Child", function()
        local child

        before_each(function()
            child = Child()
        end)

        it("should be kind of God and Parent class", function()
            assert.truthy(child.kindOf(Parent))
            assert.truthy(child.kindOf(God))
        end)

        it("should not be kind of Satan", function()
            assert.falsy(child.kindOf(Satan))
        end)

        it("should be kind of self", function()
            assert.truthy(child.kindOf(Child))
        end)
    end)
end)
