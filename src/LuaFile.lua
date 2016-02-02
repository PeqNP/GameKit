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
        local fh = io.open(path, mode)
        if not fh then
            return nil
        end
        io.input(fh)
        local blob = io.read("*all")
        io.close(fh)
        return blob
    end

    function self.write(path, contents, mode)
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
