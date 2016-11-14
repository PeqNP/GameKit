--[[
  Cuts out last 512 chunk on the end of the image.

  rearrange.lua ../path/to/image.png my-image

  @copyright 2015 Upstart Illustration LLC. All rights reserved.
--]]

require("stdout")

print("rearrange.lua v1.0a, Mar 2nd 2015. Copyright (C) 2015 Upstart Illustration LLC")
print("Current time:", os.date("%c", os.time()))
print("")

local imageName = arg[1]
if not imageName then
    print("imageName required")
    os.exit(1)
end

local target = arg[2]
if not target then
    print("target required")
    os.exit(1)
end

local outputName = target .. "-512x2048.png"

-- Cut out the left part of the image
local cmd = string.format("convert %s +repage -crop 4096x2048+0+0 %s-4096x2048.png", imageName, target)
os.execute(cmd)
stdout.r(".")
-- Cut out the far end of the image.
local cmd = string.format("convert %s +repage -crop 512x2048+4096+0 %s", imageName, outputName)
os.execute(cmd)
stdout.r("..")

print("done")
print("")

os.exit(0)
