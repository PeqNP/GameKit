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
end)

-- it: should fail to create the class if it does not conform to a Composite's protocol.
