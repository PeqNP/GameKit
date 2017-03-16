require("lang.Signal")
require("specs.Cocos2d-x")
require("specs.busted")

describe("Composite", function()
    local subject
    local subclass

    local Behavior
    local ThatBehavior
    local MyClass
    local Subclass

    before_each(function()
        local NumberProtocol = Protocol(Method("getNumber"))
        Behavior = Composite(NumberProtocol)
        function Behavior.combine(self)
            local one = 1
            function self.numberPlusOne()
                return self.getNumber() + one
            end
        end

        ThatBehavior = Composite(NumberProtocol)
        function ThatBehavior.combine(self)
            local two = 2
            function self.numberPlusTwo()
                return self.getNumber() + two
            end
        end

        MyClass = Class()
        MyClass.combine(Behavior)
        function MyClass.new(self)
            function self.getNumber()
                return 10
            end
        end

        Subclass = Class(MyClass)
        Subclass.combine(ThatBehavior)
        function Subclass.new(self)
            function self.getNumber()
                return 20
            end
        end
    end)

    context("when creating aninstance of MyClass", function()
        before_each(function()
            subject = MyClass()
        end)

        it("should combine Behavior into MyClass", function()
            assert.equals(10, subject.getNumber())
            assert.equals(11, subject.numberPlusOne())
        end)

        it("should be composite of Behavior", function()
            assert.truthy(subject.hasComposite(Behavior))
            assert.truthy(MyClass.hasComposite(Behavior))
        end)

        it("should not have composite of ThatBehavior", function()
            assert.falsy(MyClass.hasComposite(ThatBehavior))
        end)
    end)

    context("when creating instance of Subclass", function()
        before_each(function()
            subject = Subclass()
        end)

        it("should combine Behavior and ThatBehavior into Subclass", function()
            assert.equals(20, subject.getNumber())
            assert.equals(21, subject.numberPlusOne())
            assert.equals(22, subject.numberPlusTwo())
        end)

        it("should have composite of Behavior", function()
            assert.truthy(subject.hasComposite(Behavior))
            assert.truthy(Subclass.hasComposite(Behavior))
        end)

        it("should have composite of ThatBehavior", function()
            assert.truthy(subject.hasComposite(ThatBehavior))
            assert.truthy(Subclass.hasComposite(ThatBehavior))
        end)
    end)

    context("when subject and Composite have the same method", function()
        before_each(function()
            local Override = Class()
            Override.combine(Behavior)
            function Override.new(self)
                function self.getNumber()
                    return 1
                end
                function self.numberPlusOne()
                    return -1
                end
            end

            subject = Override()
        end)

        it("should not have overriden the class's numberPlusOne method", function()
            assert.equals(1, subject.getNumber())
            assert.equals(-1, subject.numberPlusOne())
        end)
    end)

    context("when initializing a Composite", function()
        local subject2

        before_each(function()
            local NumberProtocol = Protocol(Method("getNumber"))
            local Initialize = Composite(NumberProtocol)
            function Initialize.combine(self)
                local one = 1
                local value
                function self.numberPlusOne()
                    return one + value
                end
                return function()
                    value = self.getNumber()
                end
            end

            local MyClass = Class()
            MyClass.combine(Initialize)
            function MyClass.new(self)
                function self.getNumber()
                    return 77
                end
            end

            local Subclass = Class(MyClass)
            Subclass.combine(Initialize)
            function Subclass.new(self)
                function self.getNumber()
                    return 79
                end
            end

            subject = MyClass()
            subject2 = Subclass()
        end)

        it("should return the correct number", function()
            assert.equals(77, subject.getNumber())
            assert.equals(78, subject.numberPlusOne())
        end)

        it("should return the correct number", function()
            assert.equals(79, subject2.getNumber())
            assert.equals(80, subject2.numberPlusOne())
        end)

        it("should no longer have initializers", function()
            assert.falsy(subject._initializers)
            assert.falsy(subject2._initializers)
        end)
    end)

    xcontext("when a class doesn't implement a Composite's Protocol", function()
        before_each(function()
            local NothingBurger = Class()
            NothingBurger.combine(Behavior)
            function NothingBurger.new(self) end

            subject = NothingBurger()
        end)

        it("should not create an instance of NothingBurger", function()
            assert.falsy(subject)
        end)
    end)
end)

-- it: should fail to create the class if it does not conform to a Composite's protocol.
