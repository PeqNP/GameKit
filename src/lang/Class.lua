--
-- @copyright 2015 Upstart Illustration LLC. All rights reserved.
--

require "lang.Protocol"

--
-- Factory method for creating new classes.
--
function Class()
    local class = {}
    class.__index = class

    -- Class information --
    local info = debug.getinfo(2, "Sl")
    local className = string.split(info.source, "/")
    className = string.split(className[#className], "%.")
    className = className[1]

    function class.getInfo()
        return info
    end

    -- Prints detailed information about the class.
    function class.__info()
        return string.format("Instantiated in file (%s) on line (%d)", info.source, info.currentline)
    end

    -- Subclassing --
    local extends

    function class.extends(e)
        if extends then
            assert(false, string.format("Can not extend class (%s) more than once", class.__info()))
        end
        if e == class then
            assert(false, string.format("A class can not extend itself (%s)", class.__info()))
        end
        extends = e
    end

    function class.kindOf(kind)
        if kind == class then
            return true
        end
        if extends then
            return extends.kindOf(kind)
        end
        return false
    end

    -- Protocol --
    local protocols = {}

    function class.implements(...)
        local arg = {...}
        for _, protocol in ipairs(arg) do
            table.insert(protocols, protocol)
        end
    end

    function class.conformsTo(protocol)
        for _, p in ipairs(protocols) do
            if protocol == p then
                return true
            end
        end
        return false
    end

    function class.getProtocols()
        return protocols
    end

    local validated = false
    local function validate(instance)
        if #protocols == 0 then
            validated = true
            return
        end
        for _, protocol in ipairs(protocols) do
            protocol.validate(instance)
        end
        validated = true
    end

    -- Factory --
    setmetatable(class, {
        __call = function (cls, ...)
            if not cls or type(cls.new) ~= "function" then
                assert(false, string.format("(%s).new must be implemented", className))
            end

            local self = extends and extends() or {}
            cls.new(self, ...)

            function self.getClass()
                return class
            end

            function self.getClassName()
                return className
            end

            function self.conformsTo(protocol)
                return class.conformsTo(protocol)
            end

            function self.kindOf(c)
                return class.kindOf(c)
            end

            if not validated then
                validate(self)
            end

            return self
        end,
    })

    -- Singleton --
    class.singleton = false

    return class
end

--
-- Creates a singleton instance of class.
--
function Singleton(class, ...)
    if class.singleton then
        assert(false, string.format("Can not redefine the singleton instance of class (%s)", class.__info()))
    end
    class.singleton = class(...)
end
