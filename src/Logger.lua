--
-- Provides logging mechansim.
--
-- @copyright 2015 Upstart Illustration LLC. All rights reserved.
--

Logger = Class()

LogLevel = enum(0
  , 'Debug'
  , 'Info'
  , 'Warning'
  , 'Error'
  , 'Severe'
)

-- By default, print to stdout using the built-in Lua 'print' method.
Logger.pipe = print

function Logger.new(self)
    local level

    function self.init(_level)
        level = _level and _level or LogLevel.Debug
    end

    function self.getLevel()
        return level
    end

    function self.setLevel(_level)
        level = _level
    end

    function self.d(message, ...)
        if level > LogLevel.Debug then return end
        Logger.pipe(string.format("D: " .. message, ...))
    end

    function self.i(message, ...)
        if level > LogLevel.Info then return end
        Logger.pipe(string.format("I: " .. message, ...))
    end

    function self.w(message, ...)
        if level > LogLevel.Warning then return end
        Logger.pipe(string.format("W: " .. message, ...))
    end

    function self.e(message, ...)
        if level > LogLevel.Error then return end
        Logger.pipe(string.format("E: " .. message, ...))
    end

    function self.s(message, ...)
        Logger.pipe(string.format("S: " .. message, ...))
    end

    --[[ Specific for Cocos2d-x ]]--

    function self.position(tag, x, y)
        self.d("%s: x(%s) y(%s)", tag, x, y)
    end

    function self.point(tag, pt)
        self.d("%s: x(%s) y(%s)", tag, pt.x, pt.y)
    end

    function self.point3d(tag, pt)
        self.d("%s: x(%s) y(%s) z(%s)", tag, pt.x, pt.y, pt.z)
    end

    function self.rect(tag, rect)
        self.d("%s: x(%s) y(%s) w(%s) h(%s)", tag, rect.x, rect.y, rect.width, rect.height)
    end

    function self.size(tag, size)
        self.d("%s: w(%s) h(%s)", tag, size.width, size.height)
    end

    function self.glError(tag)
        local err = gl.getError()
        if err ~= 0 then
            Log.e("%s: OpenGL error (%s)", tag, err)
        end
    end
end

Log = Logger()
