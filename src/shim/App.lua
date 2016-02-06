--
-- @copyright (c) 2016 Upstart Illustration LLC. All rights reserved.
--

local main = require("shim.System")
local music = require("shim.Music")

local shim = {}

local director = main.Director()

function shim.IsPaused()
    return director:isPaused()
end

function shim.Pause()
    if not shim.IsPaused() then
        director:pause()
        director:stopAnimation()
        music.Pause()
    end
end

function shim.Resume()
    if shim.IsPaused() then
        director:startAnimation()
        music.Resume()
        director:resume()
    end
end

return shim
