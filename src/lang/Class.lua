
--[[ Factory method for creating new classes. ]]--
function Class()
    local class = {}
    class.__index = class

    -- Class information
    local info = debug.getinfo(2, "Sl")
    class.info = {
        source = info.source
      , line = info.currentline
    }
    local className = string.split(info.source, "/")
    className = string.split(className[#className], "%.")
    className = className[1]
    class.getClass = function()
        return className
    end

    setmetatable(class, {
        __call = function (cls, ...)
            local c = cls.new(...)
            if c then -- Required if the module failed to load.
                c.getClass = function()
                    return className
                end
            end
            return c
        end,
    })
    -- Singleton instance of class.
    class.singleton = false
    return class
end

--[[ Creates a singleton instance on 'class'. ]]--
function Singleton(class, ...)
    class.singleton = class(...)
end
