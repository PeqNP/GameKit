require("lang.Signal")
local ServiceLocator = require("heroin.ServiceLocator")

-- Dummy classes
local MyClass = Class()
function MyClass.new(self)
end

local SameClass = Class()
function SameClass.new(self)
    local id
    function self.init(i)
        id = i
    end
    function self.getId()
        return id
    end
end

local MyContainer = Class()
MyContainer.implements("heroin.Container")
function MyContainer.new(self)
    local deps = {
        class = MyClass(),
        same1 = SameClass(1),
        same2 = SameClass(2)
    }
    function self.getDependencies()
        return deps
    end
end

-- Tests
describe("ServiceLocator", function()
    local subject

    before_each(function()
        subject = ServiceLocator()
    end)

    context("registering a dependency", function()
        local container

        before_each(function()
            container = MyContainer()
            subject.registerContainer(container)
        end)

        it("should return dependency", function()
            local inst = subject.getDependency(MyClass)
            assert.truthy(inst.kindOf(MyClass))
        end)

        it("should return correct SameClass instance", function()
            local inst = subject.getDependency("same1")
            assert.truthy(inst.kindOf(SameClass))
            assert.equal(inst.getId(), 1)

            local inst = subject.getDependency("same2")
            assert.truthy(inst.kindOf(SameClass))
            assert.equal(inst.getId(), 2)
        end)

        -- it: should crash the app if dependency is not found.

        context("when registering the same dependencies", function()
            -- it: should crash the app if dependency is already registered.
        end)
    end)
end)

describe("Heroin", function()
    it("should have created a global singleton", function()
        assert.truthy(ServiceLocator.singleton)
    end)

    it("should have created 'inject' method", function()
        assert.equal(type(ServiceLocator.inject), "function")
    end)
end)
