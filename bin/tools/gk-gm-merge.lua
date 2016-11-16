--[[
  Merges multiple images into one image.

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

print("merge.lua v1.0a, Mar 6th 2015. Copyright (C) 2015 Upstart Illustration LLC")
print("Current time:", os.date("%c", os.time()))
print("")

local function main(source, target, offset, size, grid)
    local total = 0

    local pos = {x = offset.width, y = offset.height}

    for row=1, grid.rows do
        for col=1, grid.columns do
            total = total + 1
            local cmd = string.format("composite -compose Dst_Over -geometry +%d+%d output/%s-%02d.png %s %s", pos.x, pos.y, target, total, source, source)
            --print("Command:", cmd)
            os.execute(cmd)
            stdout.r(string.rep(".", total))
            -- Move to the right
            pos.x = pos.x + size.width
            -- @todo Add logic to to move to the next row
        end
    end

    print("done\n")
    print("Total merged:", total)
end

--[[ Command Line ]]--

local source = arg[1]
local target = arg[2]
local x = tonumber(arg[3])
local y = tonumber(arg[4])
local width = tonumber(arg[5])
local height = tonumber(arg[6])
local rows = tonumber(arg[7])
local columns = tonumber(arg[8])

if not source then
    print("source required")
    os.exit(1)
end

if not target then
    print("target required")
    os.exit(1)
end

if not x or x < 0 then
    print("x >= 0 required", x)
    os.exit(1)
end

if not y or y < 0 then
    print("y >= 0 required")
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

local offset = {
    width = x
  , height = y
}

local size = {
    height = height
  , width = width
}

local grid = {
    rows = rows
  , columns = columns
}

main(source, target, offset, size, grid)

os.exit(0)
