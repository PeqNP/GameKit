--
-- Manages which tiers can be presented.
--
-- @todo Filter adunits and tiers to have the highest paid tiers displayed first.
-- @todo Add a 'stylize' parameter that is used to style the button being presented.
--
-- @copyright Upstart Illustration LLC. All rights reserved.
--

local AdVendor = Class()

-- 
--  @param AdManifest
--  @param configMatches - function used to determine if the config matches criteria of the current app state.
--                         must return 'true', if the tier config matches. 'false', otherwise.
--
function AdVendor.new(self)
    local style
    local adUnits
    local fn__configMatches
    local unitPos = 1

    function self.init(_style, _adUnits, _fn)
        style = _style
        adUnits = _adUnits
        fn__configMatches = _fn
    end

    function self.reset()
        unitPos = 1
    end

    function self.getNextAdUnits(amount)
        if not adUnits or #adUnits == 0 then -- #adUnits condition is untested
            return nil
        end
        local ret = {} -- Add units to return.
        local currPos = unitPos
        while true do
            local adUnit = adUnits[unitPos]
            -- Add one ad unit, if validator passes.
            if adUnit.isActive() then
                local config = adUnit.getConfig()
                if config and fn__configMatches then
                    local matches, key = fn__configMatches(config)
                    if matches then
                        -- @todo have to create a key for this unit so that the click file
                        -- can be refererend specifically to this AdUnit.
                        table.insert(ret, adUnit)
                    end
                elseif not config then
                    table.insert(ret, adUnit)
                end
            end
            unitPos = unitPos + 1
            if unitPos > #adUnits then
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

    function self.getNextAdUnitButtons(amount, fn__callback)
        local buttons = {}
        local nextUnits = self.getNextAdUnits(amount)
        for _, adUnit in ipairs(nextUnits) do
            local function fn__clicked()
                fn__callback(adUnit)
            end
            local button = style.getButton(adUnit, fn__clicked)
            table.insert(buttons, button)
        end
        return buttons
    end
end

return AdVendor
