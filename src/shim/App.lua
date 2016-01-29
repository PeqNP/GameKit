--
-- @copyright (c) 2016 Upstart Illustration LLC. All rights reserved.
--

local main = require("shim.Main")
local music = require("shim.Music")

local shim = {}

local director = main.Director()

function shim.IsPaused()
    return director:isPaused()
end

function shim.Pause()
    if not shim.isPaused() then
        director:pause()
        director:stopAnimation()
        music.pause()
    end
end

function shim.Resume()
    if shim.isPaused() then
        director:startAnimation()
        music.resume()
        director:resume()
    end
end

return shim
