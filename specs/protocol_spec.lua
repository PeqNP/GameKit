require "lang.Signal"

local SpecProtocol = require("specs.SpecProtocol")

describe("Method", function()
    local subject

    describe("when required", function()
        before_each(function()
            subject = Method("foo", true)
        end)

        it("should have correct name", function()
            assert.equal("foo", subject.getName())
        end)
        
        it("should be required", function()
            assert.truthy(subject.isRequired())
        end)
    end)

    describe("when not required", function()
        before_each(function()
            subject = Method("foo", false)
        end)

        it("should NOT be required", function()
            assert.falsy(subject.isRequired())
        end)
    end)

    describe("when required not given", function()
        before_each(function()
            subject = Method("foo")
        end)

        it("should be required by default", function()
            assert.truthy(subject.isRequired())
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
        local MyClass

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

    describe("implementing the SpecProtocol using path", function()
        local instance
        local MyClass

        before_each(function()
            MyClass = Class()
            MyClass.implements("specs.SpecProtocol")

            function MyClass.new(self)
                function self.getSpec()
                    return "Implemented protocol using path"
                end
            end

            instance = MyClass()
        end)

        it("should conform to the SpecProtocol", function()
            assert.truthy(instance.conformsTo(SpecProtocol))
        end)

        it("should not conform to a protocol it does not implement", function()
            assert.falsy(instance.conformsTo({}))
        end)
    end)

    describe("implementing TestProtocol as a subclass", function()
        local instance
        local MyClass
        local MySubclass

        before_each(function()
            MyClass = Class()
            MyClass.implements(TestProtocol, DummyProtocol)
            MySubclass = Class(MyClass)

            function MyClass.new(self)
                function self.testMethod()
                end

                function self.dummyMethod()
                end
            end
            function MySubclass.new(self)
            end

            instance = MySubclass()
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

    --[[
    describe("test failed protocol", function()
        local MyClass

        before_each(function()
            MyClass = Class()
            MyClass.implements("specs.NotAClass")
        end)

        it("should NOT have a value", function()
            assert.falsy(MyClass)
        end)
    end)
    --]]
end)
