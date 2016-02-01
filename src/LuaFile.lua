--
-- Provides wrapper around Lua file module.
--
-- @copyright (c) 2016 Upstart Illustration LLC. All rights reserved.
--

LuaFile = Class()

function LuaFile.new(self)
    local path

    function self.init(_path)
        path = _path
    end

    function self.getPath()
        return path
    end

    function self.getContents()
        local fh = io.open(path, "r")
        if not fh then
        io.input(fh)
        local blob = io.read("*all")
        io.close(fh)
        return blob
    end

    function self.setContents()
        -- @todo
    end
end
