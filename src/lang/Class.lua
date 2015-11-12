--
-- @copyright 2015 Upstart Illustration LLC. All rights reserved.
--

require "lang.Protocol"

--
-- Factory method for creating new classes.
--
function Class(extends)
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
    function class.__tostring()
        return string.format("Instantiated in file (%s) on line (%d)", info.source, info.currentline)
    end

    function class.getClassName()
        return className
    end

    -- Abstract --
    local abstract
    function class.abstract(a)
        abstract = a
    end

    -- Returns the protocol that every subclass of this class must conform to.
    function class.protocol()
        return abstract
    end

    -- Subclassing --
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
        local args = {...}
        table.extend(protocols, args)
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

    -- Ensure any abstract methods are being implemented in the subclass.
    if extends then
        local protocol = extends.protocol()
        if protocol then
            class.implements(protocol)
        end
    end

    -- Allocates an instance of the object. Does NOT call init.
    function class.alloc(self)
        if extends then
            extends.alloc(self)
        end

        -- Super init
        local __super = self.init

        class.new(self)

        -- Make sure super is called if init is not the same.
        if __super and __super ~= self.init then
            local __init = self.init
            function self.init(...)
                __super(__init(...))
            end
        end

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
    end

    -- Factory --
    setmetatable(class, {
        __call = function (cls, ...)
            if not cls or type(cls.new) ~= "function" then
                assert(false, string.format("function (%s).new() must be implemented", className))
            end

            local self = {}
            class.alloc(self)

            if self.init then
                self.init(...)
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
        assert(false, string.format("Can not redefine the singleton instance of class (%s)", class.__tostring()))
    end
    class.singleton = class(...)
end
