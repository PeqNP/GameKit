--[[
   Provides wrapper around Lua file module.

   @copyright (c) 2016 Upstart Illustration LLC. All rights reserved.
  ]]

local LuaFile = {}

function LuaFile.read(path, mode)
    if not mode then
        mode = "r"
    end
    local fh = io.open(path, mode)
    if not fh then
        return nil
    end
    io.input(fh)
    local contents = io.read("*all")
    io.close(fh)
    return contents
end

function LuaFile.write(path, contents, mode)
    if not mode then
        mode = "w"
    end
    local fh = io.open(path, mode)
    io.output(fh)
    io.write(contents)
    io.close(fh)
end

return LuaFile
