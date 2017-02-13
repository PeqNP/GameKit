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

    it("should have set 'inject' to 'getDependency'", function()
        assert.equal(subject.inject, subject.getDependency)
    end)

    context("registering a container", function()
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

    context("registering a dependency", function()
        local my

        before_each(function()
            my = MyClass()
            subject.registerDependency("my", my)
        end)

        it("should return dependency", function()
            local inst = subject.getDependency("my")
            assert.truthy(inst.kindOf(MyClass))
            assert.equal(inst, my)
        end)
    end)
end)
