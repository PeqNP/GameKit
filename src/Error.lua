--
-- @copyright 2015 Upstart Illustration LLC. All rights reserved.

ErrorCode = enum(1
  , 'ValueError'
)

Error = Class()

function Error.tostring(err)
    return string.format("Code (%d) Message (%s) Params (%s)", err.code, err.message, unpack(err.params))
end

Error.mt = {}
Error.mt.__tostring = Error.tostring

function Error.new(self, code, message, info)
    self.code = code
    self.message = message
    self.info = info

    setmetatable(self, Error.mt)
end
