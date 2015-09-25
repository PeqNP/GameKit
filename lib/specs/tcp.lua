--[[ Mock TCP class.

I chose to do it this way as there is no obvious way to mock the return type of
socket.connect().

@copyright 2015 Upstart Illustration LLC

--]]

require "specs.LuaClass"
require "Logger"

_TCP = class()

function _TCP:init()
    self.secs = 100
end

function _TCP:timeout(s)
    Log.d("timeout(%s)", s)
    secs = s
end

function _TCP:send(data)
    Log.d("TCP.send(%s)", data)
    local post = {} -- ...
end

function _TCP:receive()
    local pattern, prefix -- ...
end

function _TCP:close()
end
