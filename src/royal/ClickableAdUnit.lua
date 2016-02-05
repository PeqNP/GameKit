--
-- @copyright Upstart Illustration LLC. All rights reserved.
--

local shim = require("shim.System")

local ClickableAdUnit = Class("royal.AdUnit")

function ClickableAdUnit.new(self, init)
    local config
    local key

    function self.init(_config, u, _key)
        init(u.getId(), u.getStartDate(), u.getEndDate(), u.getURL(), u.getReward(), u.getTitle(), u.getConfig())
        config = _config
        key = _key
    end

    function self.getPath()
        if key then
            return string.format("id%s-key%s-click.json", self.getId(), key)
        end
        return string.format("id%s-click.json", self.getId())
    end

    function self.click()
        local ts = shim.GetTime()

        Log.i("Clicked AdUnit ID (%s) config key (%s) ts (%s)", self.getId(), key, ts)

        config.write(self.getPath(), tostring(ts))

        shim.OpenURL(self.getURL())
    end
end

return ClickableAdUnit
