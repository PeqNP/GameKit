--
-- @copyright 2015 Upstart Illustration LLC. All rights reserved.

ErrorCode = enum(1
  , 'ValueError'
)

local Error = Class()

function Error.tostring(err)
    return string.format("Code (%d) Message (%s)", err.getCode(), err.getMessage())
end

Error.mt = {}
Error.mt.__tostring = Error.tostring

function Error.new(self)
    local code
    local message
    local info

    function self.init(c, m, i)
        code = c
        message = m
        info = i
    end

    function self.getCode()
        return code
    end

    function self.getMessage()
        return message
    end

    function self.getInfo()
        return info
    end

    setmetatable(self, Error.mt)
end

return Error
