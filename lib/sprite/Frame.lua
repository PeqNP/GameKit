--[[
  Provides data structure that contains a frame and its respective
  bbox offset.

  @author Eric Chamberlain
  @copyright 2014 Upstart Illustration LLC. All rights reserved.
--]]

Frame = Class()

function Frame.new(_frameNum, _bbox)
    local self = {}
    self.number = _frameNum
    if _bbox then
        self.bbox = {x = _bbox[1], y = _bbox[2], width = _bbox[3], height = _bbox[4]}
    else
        self.bbox = false
    end
    self.sprite = false
    return self
end
