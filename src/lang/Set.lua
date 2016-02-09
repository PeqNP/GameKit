--
-- Provides primitive Set database.
--
-- FIXME: This class is untested.
--
-- @copyright (c) 2014 Upstart Illustration LLC. All rights reserved.
--

Set = Class()

function Set.tostring(self)
    local s = "{"
    local sep = ""
    for e in pairs(self.getValues()) do
        s = s .. sep .. e
        sep = ", "
    end
    return s .. "}"
end

Set.mt = {}
Set.mt.__tostring = Set.tostring

function Set.new(self)
    local values = {}

    function self.init(vals)
        for _, v in ipairs(vals) do values[v] = true end
    end

    function self.getValues()
        return values
    end

    function self.union(b)
        local res = Set()
        for k in pairs(values) do res[k] = true end
        for k in pairs(b.getValues()) do res[k] = true end
        return res
    end

    function self.intersection(b)
        local res = Set()
        local bValues = b.getValues()
        for k in pairs(values) do
            res[k] = bValues[k]
        end
        return res
    end

    --
    -- Determine if value exists in set.
    --
    -- @param mixed Value to check existance for
    -- @return boolean true if existing. false otherwise
    --
    function self.contains(key)
        return values[key] ~= nil
    end

    setmetatable(self, Set.mt)
end
