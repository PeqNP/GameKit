--
-- Provides wrapper around Lua file module.
--
-- @copyright (c) 2016 Upstart Illustration LLC. All rights reserved.
--

local LuaFile = Class()

function LuaFile.new(self)
    function self.read(path, mode)
        if not mode then
            mode = "r"
        end
        --Log.d("LuaFile:read(%s, %s)", path, mode)
        local fh = io.open(path, mode)
        if not fh then
            --Log.d("LuaFile:read() - No file contents")
            return nil
        end
        io.input(fh)
        local contents = io.read("*all")
        io.close(fh)
        --Log.d("LuaFile:read() - contents (%s)", contents)
        return contents
    end

    function self.write(path, contents, mode)
        if not mode then
            mode = "w"
        end
        --Log.d("LuaFile:write(%s, %s, %s)", path, contents, mode)
        local fh = io.open(path, mode)
        io.output(fh)
        io.write(contents)
        io.close(fh)
    end
end

return LuaFile
