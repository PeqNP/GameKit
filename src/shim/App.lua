--
-- @copyright (c) 2016 Upstart Illustration LLC. All rights reserved.
--

local shim = {}

local director
local music

function shim.init(d, m)
    director = d
    music = m
end

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
