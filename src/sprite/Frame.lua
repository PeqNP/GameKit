--
-- Provides data structure that contains a frame and its respective
-- bbox offset.
--
-- @copyright 2014 Upstart Illustration LLC. All rights reserved.
--

local Frame = Class()

function Frame.new(self)
    self.sprite = false

    function self.init(frameNum, bbox)
        self.number = frameNum
        if bbox then
            self.bbox = {x = bbox[1], y = bbox[2], width = bbox[3], height = bbox[4]}
        else
            self.bbox = false
        end
    end
end

return Frame
