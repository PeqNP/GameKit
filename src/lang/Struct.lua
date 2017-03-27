
function Struct()
    local struct = {}
    struct.__index = struct

    -- Class information --
    local info = debug.getinfo(2, "Sl")
    local structName = string.split(info.source, "/") -- remove everything before path
    -- @fixme This doesn't work with Lua 5.1. I'm not sure if it's because of
    -- the escape character used or what.
    structName = string.split(structName[#structName], "%.") -- remove '.lua[c|o]' extension
    structName = structName[1]

    function struct.__tostring()
        return string.format("Instantiated in file (%s) on line (%d)", info.source, info.currentline)
    end

    -- Factory --
    setmetatable(struct, {
        __call = function (cls, ...)
            if not cls then
                Signal.fail(string.format("(%s) is not a struct", structName))
            end
            if type(cls.new) ~= "function" then
                Signal.fail(string.format("function %s.new() must be implemented", structName))
            end

            local self = {}
            struct.new(self, ...)

            return self
        end,
    })

    return struct
end
