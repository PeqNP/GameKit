--[[
  Cuts images in specified sized chunks.

  @copyright 2015 Upstart Illustration LLC. All rights reserved.
--]]

function set_path()
    local path = arg[0]
    local index = string.find(path, "/[^/]*$")
    if not index or index == 0 then return end
    local parent_dir = path:sub(0, index)
    package.path = parent_dir .. "?.lua;" .. package.path
end
set_path()

require("stdout")

print("cut.lua v1.0a, Feb 27th 2015. Copyright (C) 2015 Upstart Illustration LLC")
print("Current time:", os.date("%c", os.time()))
print("")

local function main(source, target, size, grid, offset)
    local total = 0

    for row=1, grid.rows do
        for col=1, grid.columns do
            total = total + 1
            offset.height = (row-1) * size.height
            offset.width = (col-1) * size.width
            local cmd = string.format("convert '%s' -crop %sx%s+%s+%s +repage '%s-%02d.png'", source, size.width, size.height, offset.width, offset.height, target, total)
            --print("Command:", cmd)
            os.execute(cmd)
            stdout.r("\r" .. string.rep(".", total))
        end
    end

    print("done\n")
    print("Total tiles:", total)
end

--[[ Command Line ]]--

local source = arg[1]
local target = arg[2]
local width = tonumber(arg[3])
local height = tonumber(arg[4])
local rows = tonumber(arg[5])
local columns = tonumber(arg[6])

if not source then
    print("source required")
    os.exit(1)
end

if not target then
    print("target required")
    os.exit(1)
end

if not width or width < 1 then
    print("width > 1 required")
    os.exit(1)
end

if not height or height < 1 then
    print("height > 1 required")
    os.exit(1)
end

if not rows or rows < 1 then
    print("rows > 1 required")
    os.exit(1)
end

if not columns or columns < 1 then
    print("columns > 1 required")
    os.exit(1)
end

local size = {
    height = height
  , width = width
}

local grid = {
    rows = rows
  , columns = columns
}

local offset = {
    width = 0
  , height = 0
}

main(source, target, size, grid, offset)

os.exit(0)
