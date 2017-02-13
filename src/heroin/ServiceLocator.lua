--
-- Provides service location.
--
-- @copyright 2016 Upstart Illustration LLC. All rights reserved.
--

local ServiceLocator = Class()
local Container = require("heroin.Container")

function ServiceLocator.new(self)
    local dependencies = {}

    function self.registerContainer(container)
        assert(container and container.conformsTo(Container), "'container' must be a non-nil value and conform to 'Container' protocol.")
        local deps = container.getDependencies()
        for key, val in pairs(deps) do
            if dependencies[ key ] then
                assert(false, string.format("Dependency for var (%s) has already been registered", key))
            end
            dependencies[ key ] = val
        end
    end

    function self.unregisterContainer(container)
        assert(container and container.conformsTo(Container), "'container' must be a non-nil value and conform to 'Container' protocol.")
        local deps = container.getDependencies()
        for key, val in pairs(deps) do
            if dependencies[ key ] then
                dependencies[ key ] = nil
            else
                Log.w("Unregistering dependency for var (%s) which has not been registered", key)
            end
        end
    end

    function self.registerDependency(name, dependency)
        assert(name and type(name) == "string", "'name' must be a non-nil string value.")
        assert(dependency and type(dependency) == "table", "'dependency' must be a non-nil class value.")
        if dependencies[ name ] then
            assert(false, string.format("Dependency for var (%s) has already been registered", name))
        end
        dependencies[ name ] = dependency
    end

    function self.getDependency(dependency)
        local T = type(dependency)
        if T == "string" then
            local dep = dependencies[ dependency ]
            if not dep then
                assert(false, string.format("The dependency for var (%s) has not been registered", key))
            end
            return dep
        elseif T == "table" then
            for _, dep in pairs(dependencies) do
                if dependency == dep.getClass() then
                    return dep
                end
            end
            assert(false, string.format("The dependency for var (%s) has not been registered", dependency.getClassName()))
        else
            assert(false, string.format("Could not find dependency for type (%s)", T))
        end
    end
end

Singleton(ServiceLocator)

ServiceLocator.inject = ServiceLocator.singleton.getDependency

return ServiceLocator
