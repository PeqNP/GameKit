require "lang.Signal"

describe("Signal", function()
    describe("integer.between", function()
        it("should not be between if int is < to", function()
            assert.falsy(integer.between(1, 2, 4))
        end)

        it("should not be between if int is > from", function()
            assert.falsy(integer.between(5, 2, 4))
        end)

        it("should be between if 2 and 4, if 2", function()
            assert.truthy(integer.between(2, 2, 4))
        end)

        it("should be between if 2 and 4, if 3", function()
            assert.truthy(integer.between(3, 2, 4))
        end)

        it("should be between if 2 and 4, if 4", function()
            assert.truthy(integer.between(4, 2, 4))
        end)
    end)

    describe("bit ops", function()
        it("should have bit 1", function()
            assert.truthy(hasbit(1, bit(1)))
        end)

        it("should not have bit 1", function()
            assert.falsy(hasbit(0, bit(1)))
        end)

        it("should not have bit 1", function()
            assert.falsy(hasbit(2, bit(1)))
        end)

        it("should have bit 2", function()
            assert.truthy(hasbit(2, bit(2)))
        end)

        it("should have bit 1 and 2", function()
            assert.truthy(hasbit(3, bit(1)))
            assert.truthy(hasbit(3, bit(2)))
        end)

        it("should have bit 3", function()
            assert.truthy(hasbit(4, bit(3)))
        end)

        it("should NOT have bit 3", function()
            assert.falsy(hasbit(4, bit(1)))
            assert.falsy(hasbit(4, bit(2)))
        end)
    end)

    describe("math.euclid", function()
        it("should be 5", function()
            assert.equals(5, math.euclid(100, 5))
        end)

        it("should be 5", function()
            assert.equals(5, math.euclid(5, 100))
        end)

        it("should be 1", function()
            assert.equals(1, math.euclid(7, 23))
        end)

        it("should be 25", function()
            assert.equals(25, math.euclid(25, 75))
        end)
    end)

    describe("table.euclid", function()
        it("should be 5", function()
            assert.equals(5, table.euclid({5, 100, 10}))
        end)

        it("should be 5", function()
            assert.equals(5, table.euclid({100, 5, 10}))
        end)

        it("should be 5", function()
            assert.equals(5, table.euclid({100, 5, 5, 10}))
        end)

        it("should be 7", function()
            assert.equals(7, math.euclid(14, 7, 21))
        end)

        it("should be 5", function()
            assert.equals(25, table.euclid({25, 75}))
        end)
    end)
end)

describe("Protocol", function()
    local TestProtocol
    local DummyProtocol
    local testMethod
    local dummyMethod
    local definition

    before_each(function()
        testMethod = Method("testMethod", true)
        TestProtocol = Protocol(testMethod)
        dummyMethod = Method("dummyMethod", false)
        DummyProtocol = Protocol(dummyMethod)
    end)

    it("should return the methods", function()
        local methods = TestProtocol.getMethods()
        assert.equal(1, #methods)
        assert.equal(testMethod, methods[1]) -- sanity
    end)

    describe("implementing the TestProtocol", function()
        local instance

        before_each(function()
            MyClass = Class()
            MyClass.implements(TestProtocol, DummyProtocol)

            function MyClass.new(self)
                function self.testMethod()
                end

                function self.dummyMethod()
                end
            end

            instance = MyClass()
        end)

        it("should have two protocol", function()
            local protocols = MyClass.getProtocols()
            assert.equal(2, #protocols)
            assert.equal(TestProtocol, protocols[1])
            assert.equal(DummyProtocol, protocols[2])
        end)

        it("should conform to the TestProtocol", function()
            assert.truthy(instance.conformsTo(TestProtocol))
        end)

        it("should conform to the DummyProtocol", function()
            assert.truthy(instance.conformsTo(DummyProtocol))
        end)

        it("should not conform to a protocol it does not implement", function()
            assert.falsy(instance.conformsTo({}))
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

describe("Classes", function()
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
        assert.equal("signal_spec", god.getClassName())
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
