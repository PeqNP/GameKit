--
-- @copyright 2015 Upstart Illustration LLC. All rights reserved.
--

function Method(name, required)
    local self = {}

    if required == nil then
        required = true
    end

    function self.getName()
        return name
    end

    function self.isRequired()
        return required
    end

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
            if method.isRequired() and type(instance[method.getName()]) ~= "function" then
                Signal.fail(string.format("Class instance (%s) must implement protocol method (%s). %s", instance.getClassName(), method.getName(), instance.getClass().__tostring()))
            end
        end
    end

    return self
end
