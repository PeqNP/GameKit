--
-- @copyright 2015 Upstart Illustration LLC. All rights reserved.
--

require "lang.Protocol"

local function get_definition(definition, _type)
    if type(definition) == "string" then
        local module_path = definition
        definition = require(module_path)
        if type(definition) ~= "table" then
            print(string.format("Failed to load (%s) module (%s). Does the module return the (%s) definition?", _type, module_path, _type))
            os.exit(1)
        end
    end
    return definition
end

--
-- Factory method for creating new classes.
--
function Class(extends)
    local class = {}
    class.__index = class

    -- Attempt to load the subclass's module.
    extends = get_definition(extends, "class")

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

    -- Composites --
    local composites = {}

    function class.combine(...)
        local args = {...}
        for _, composite in ipairs(args) do
            table.insert(composites, composite)
        end
    end

    function class.hasComposite(c)
        for _, composite in ipairs(composites) do
            if c == composite then
                return true
            end
        end
        -- Subclasses take on the behavior of composites on their base class.
        if extends then
            return extends.hasComposite(c)
        end
        return false
    end

    -- Protocol --
    local protocols = {}

    function class.implements(...)
        local args = {...}
        local new_protocols = {}
        for _, protocol in ipairs(args) do
            protocol = get_definition(protocol, "protocol")
            table.insert(new_protocols, protocol)
        end
        table.extend(protocols, new_protocols)
    end

    function class.conformsTo(protocol)
        for _, p in ipairs(protocols) do
            if protocol == p then
                return true
            end
        end
        -- Subclasses conform to the protocol if their parent conforms to the protocol.
        if extends then
            return extends.conformsTo(protocol)
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

        self.conformsTo = class.conformsTo
        self.kindOf = class.kindOf
        self.hasComposite = class.hasComposite

        for _, composite in ipairs(composites) do
            composite.combine(self)
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
    class = get_definition(class, "class")
    if class.singleton then
        assert(false, string.format("Can not redefine the singleton instance of class (%s)", class.__tostring()))
    end
    class.singleton = class(...)
end
