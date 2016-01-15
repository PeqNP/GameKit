local match = require("luassert.match") 

local function is_kind_of(state, arguments)
    local class = arguments[1]
    return function(value)
        if type(value) == "table" and value.getClass and value.getClass() == class then
            return true
        end
        return false
    end
end

local function is_equal(state, arguments)
    local expected = arguments[1]
    return function(value)
        return table.equals(expected, value)
    end
end

function matchers_assert(assert)
    assert:register("matcher", "is_kind_of", is_kind_of)
    assert:register("matcher", "equal", is_equal)
end

return match
