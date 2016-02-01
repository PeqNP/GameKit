--
-- Provides wrapper around Lua file module.
--
-- @copyright (c) 2016 Upstart Illustration LLC. All rights reserved.
--

local LuaFile = Class()

function LuaFile.new(self)
    local path

    function self.init(_path)
        path = _path
    end

    function self.getPath()
        return path
    end

    function self.read(mode)
        if not mode then
            mode = "r"
        end
        local fh = io.open(path, mode)
        if not fh then
            return nil
        end
        io.input(fh)
        local blob = io.read("*all")
        io.close(fh)
        return blob
    end

    function self.write(contents, mode)
        if not mode then
            mode = "w"
        end
        local fh = io.open(path, mode)
        io.output(fh)
        io.write(contents)
        io.close(fh)
    end
end

return LuaFile
