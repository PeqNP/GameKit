
require "game.FXProcessor"

Level1 = Class()

function Level1.new()
    local self = {}

    local size = cc.size(100, 100)
    local fx = FXProcessor(size)
    fx.setPoint(cc.p(0,0))

    function self.getLevelDepth() return LevelDepth.Near end
    function self.getContentSize() return size end
    function self.getFXProcessor() return fx end

    return self
end

Level2 = Class()

function Level2.new()
    local self = {}

    local size = cc.size(100, 200)
    local fx = FXProcessor(size)
    fx.setPoint(cc.p(0,0))

    function self.getLevelDepth() return LevelDepth.Near end
    function self.getContentSize() return size end
    function self.getFXProcessor() return fx end

    return self
end
