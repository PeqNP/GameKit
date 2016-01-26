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

    -- Attempt to load the subclass's module.
    if type(extends) == "string" then
        local module_path = extends
        extends = require(module_path)
        if type(extends) ~= "table" then
            print(string.format("Failed to load class module (%s). Does the module return the instance to the class definition?", module_path))
            os.exit(1)
        end
    end

    -- Class information --
    local info = debug.getinfo(2, "Sl")
    local className = string.split(info.source, "/") -- remove everything before path
    -- @fixme This doesn't work with Lua 5.1. I'm not sure if it's because of
    -- the escape character used or what.
    className = string.split(className[#className], "%.") -- remove '.lua[c|o]' extension
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

        class.new(self, self.init)

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
            if not cls then
                assert(false, string.format("cls (%s) is not a class", className))
            end
            if type(cls.new) ~= "function" then
                assert(false, string.format("function %s.new() must be implemented", className))
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
