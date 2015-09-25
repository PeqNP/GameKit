--[[ Provides primitive Set database.

  @copyright 2014 Upstart Illustration LLC. All rights reserved.
--]]

Set = Class()

function Set.new(t)
    local self = {}
    self.mt = {}

    --[[ Untested ]]--
    function self.union(b)
        local res = Set({})
        for k in pairs(self.mt) do res[k] = true end
        for k in pairs(b.mt) do res[k] = true end
        return res
    end

    --[[ Untested ]]--
    function self.intersection(b)
        local res = Set({})
        for k in pairs(self.mt) do
            res[k] = b.mt[k]
        end
        return res
    end

    --[[
        Determine if value exists in set.

        @param mixed Value to check existance for
        @return boolean true if existing. false otherwise
    --]]
    function self.contains(val)
        return self.mt[val] ~= nil
    end

    function self.tostring()
        local s = "{"
        local sep = ""
        for e in pairs(self.mt) do
            s = s .. sep .. e
            sep = ", "
        end
        return s .. "}"
    end

    function self.print()
        print(self.tostring())
    end

    for _, l in ipairs(t) do self.mt[l] = true end
    return self
end
