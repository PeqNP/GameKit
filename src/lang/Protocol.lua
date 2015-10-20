--
-- @copyright 2015 Upstart Illustration LLC. All rights reserved.
--

function Method(name, required)
    local self = {}

    self.name = name
    self.required = required

    return self
end

function Protocol(...)
    local self = {}

    local methods = {...}

    function self.getMethods()
        return methods
    end

    function self.validate(instance)
        if #methods == 0 then return end
        for _, method in ipairs(methods) do
            if method.required and type(instance[method.name]) ~= "function" then
                assert(false, string.format("Class instance (%s) must implement protocol method (%s). %s", instance.getClassName(), method.name, instance.getClass().__info()))
            end
        end
    end

    return self
end
