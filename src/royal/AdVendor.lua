--
-- Manages which tiers can be presented.
--
-- @todo Filter adunits and tiers to have the highest paid tiers displayed first.
-- @todo Add a 'stylize' parameter that is used to style the button being presented.
--
-- @copyright Upstart Illustration LLC. All rights reserved.
--

local shim = require("shim.System")

local AdVendor = Class()

-- 
--  @param AdManifest
--  @param configMatches - function used to determine if the config matches criteria of the current app state.
--                         must return 'true', if the tier config matches. 'false', otherwise.
--
function AdVendor.new(self)
    local manifest
    local fn__configMatches
    local unitPos = 1

    function self.init(_manifest, _fn)
        manifest = _manifest
        fn__configMatches = _fn
    end

    function self.reset()
        unitPos = 1
    end

    function self.getNextTiers(amount)
        if not manifest then
            return nil
        end
        local units = manifest.getAdUnits()
        if #units == 0 then -- @fixme untested
            return nil
        end
        local ret = {} -- Add units to return.
        local currPos = unitPos
        while true do
            local adUnit = units[unitPos]
            if adUnit.isActive() then
                local tiers = adUnit.getTiers()
                -- Add one tier, per add unit, if validator passes.
                -- @todo Round-robin tiers if they have the same config.
                for _, t in ipairs(tiers) do
                    if t.isActive() then
                        if t.config and fn__configMatches and fn__configMatches(t.config) then
                            table.insert(ret, t)
                            break
                        elseif not t.config then
                            table.insert(ret, t)
                            break
                        end
                    end
                end
            end
            unitPos = unitPos + 1
            if unitPos > #units then
                unitPos = 1
            end
            -- Back to the first ad we will vend. Do not dupe and return only
            -- what we have.
            if currPos == unitPos then
                break
            end
            if #ret >= amount then
                break
            end
        end
        return ret
    end

    function self.getNextTierButtons(amount, fn__callback)
        local buttons = {}
        local tiers = self.getNextTiers(amount)
        for _, tier in ipairs(tiers) do
            local sprite = tier.getButtonSprite() -- @todo Call 'stylize' fn here.
            local button = shim.SpriteButton(sprite, sprite)
            local function fn__clicked()
                fn__callback(tier)
            end
            -- @fixme Calling a Cocos2d-x specific method!
            button:registerScriptTapHandler(fn__clicked)
            table.insert(buttons, button)
        end
        return buttons
    end
end

return AdVendor
