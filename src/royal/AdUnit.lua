--
-- Provides an AdUnit, a structure that defines the version, id and tiers
-- of a given Ad.
--
-- @copyright (c) 2015 Upstart Illustration LLC. All rights reserved.
--

local shim = require("shim.System")

local AdUnit = Class()

function AdUnit.new(self)
    local id
    local startDate
    local endDate
    local url
    local reward
    local title
    local config

    function self.init(_id, _startDate, _endDate, _url, _reward, _title, _config)
        id = _id
        startDate = _startDate
        endDate = _endDate
        url = _url
        reward = _reward
        title = _title
        config = _config
    end

    function self.isActive()
        local ctime = shim.GetTime()
        if ctime < startDate or ctime > endDate then
            return false
        end
        return true
    end

    function self.getId()
        return id
    end

    function self.getStartDate()
        return startDate
    end

    function self.getEndDate()
        return endDate
    end

    function self.getURL()
        return url
    end

    function self.getReward()
        return reward
    end

    function self.getTitle()
        return title
    end

    function self.getConfig()
        return config
    end

    -- FIXME: These methods probably belong somewhere else.

    function self.getBannerName()
        return string.format("banner-%s.png", id)
    end

    function self.getButtonName()
        return string.format("button-%s.png", id)
    end
end

return AdUnit
