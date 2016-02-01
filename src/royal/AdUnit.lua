--
-- Provides an AdUnit, a structure that defines the version, id and tiers
-- of a given Ad.
--
-- @copyright (c) 2015 Upstart Illustration LLC. All rights reserved.
--

local AdUnit = Class()

function AdUnit.new(self)
    local id
    local startDate
    local endDate
    local url
    local reward
    local title
    local config

    function self.init(id, startdate, enddate, url, reward, title, config)
        id = _id
        startDate = _startDate
        endDate = _endDate
        url = _url
        reward = _reward
        title = _title
        config = _config
    end

    function self.isActive()
        local ctime = socket.gettime()
        if ctime < startdate or ctime > enddate then
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
end

return AdUnit
