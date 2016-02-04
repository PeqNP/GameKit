--
-- @copyright Upstart Illustration LLC. All rights reserved.
--

local shim = require("shim.System")

local ClickableAdUnit = Class("royal.AdUnit")

function ClickableAdUnit(self, init)
    local config
    local key

    function self.init(_config, u, _key)
        init(u.getId(), u.getStartDate(), u.getEndDate(), u.getURL(), u.getReward(), u.getTitle(), u.getConfig())
        config = _config
        key = _key
    end

    function self.getPath()
        return string.format("id%s-key%s-click.json", self.getId(), key)
    end

    function self.click()
        local ts = shim.GetTime()

        Log.i("AdUnit ID (%s) config (%s) clicked on (%s)", self.getId(), path, ts)

        config.write(self.getPath(), tostring(ts))

        shim.OpenURL(self.getURL())
    end
end

return ClickableAdUnit
