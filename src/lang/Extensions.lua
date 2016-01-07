--[[
  Creates an enumerated list of values.

  This also creates two variables 'MIN' and 'MAX' to indicate the bounds
  of the enumeration.

  @param The starting value of the first enumeration
  @param List of string values that represent the respective enum value.

--]]
function enum(start, ...)
    local e = {}
    e['MIN'] = start
    local tbl = {...}
    for i, v in pairs(tbl) do
        e[v] = start
        start = start + 1
    end
    e['MAX'] = start - 1
    return e
end

--[[
  Creates an enumeration where the key is also the value.

  @param The starting value of the first enumeration
  @param List of string values that represent the respective enum value.

--]]
function enumkv(start, ...)
    local e = {}
    local tbl = {...}
    for i, v in pairs(tbl) do
        e[v] = v
    end
    return e
end

--[[
  Creates an enumerated bitmask.

  Currently 'start' is not supported and always defaults to 0x01.

  @param The starting value of the first bitmask value.
  @param List of string values that represent the respective enum value.

--]]
function bitmask(start, ...)
    local e = {}
    local tbl = {...}
    for i, v in pairs(tbl) do
        --e[v] = bit32.lshift(1, i-1)
        e[v] = 2 ^ (i - 1)
    end
    return e
end

function bit(p)
  return 2 ^ (p - 1)  -- 1-based indexing
end

-- Typical call:  if hasbit(x, bit(3)) then ...
function hasbit(x, p)
  return x % (p + p) >= p       
end

function setbit(x, p)
  return hasbit(x, p) and x or x + p
end

function clearbit(x, p)
  return hasbit(x, p) and x - p or x
end

--[[ Convenience function returns time in sub-second precision. ]]--
gettime = socket.gettime

--[[ Create shallow copy of table.
  http://lua-users.org/wiki/CopyTable : Shallow Copy ]]--
function shallowcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in pairs(orig) do
            copy[orig_key] = orig_value
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

--[[ Split a string using pattern. ]]--
function string.split(str, pat)
    local t = {}  -- NOTE: use {n = 0} in Lua-5.0
    local fpat = "(.-)" .. pat
    local last_end = 1
    local s, e, cap = str:find(fpat, 1)
    while s do
        if s ~= 1 or cap ~= "" then
            table.insert(t,cap)
        end
        last_end = e+1
        s, e, cap = str:find(fpat, last_end)
    end
    if last_end <= #str then
        cap = str:sub(last_end)
        table.insert(t, cap)
    end
    return t
end

--[[ Determine if a value is contained within a table.
  
@param Table containing values to search (haystack)
@param Value (needle) to find in table
@return true when value is in table. false, otherwise.

--]]
function table.contains(tbl, val)
    for _, v in ipairs(tbl) do
        if val == v then
            return true
        end
    end
    return false
end

function table.extend(table1, table2)
    for k, v in ipairs(table2) do
        table.insert(table1, v)
    end
end

function table.equals(o1, o2, ignore_mt)
    if o1 == o2 then return true end
    local o1Type = type(o1)
    local o2Type = type(o2)
    if o1Type ~= o2Type then return false end
    if o1Type ~= 'table' then return false end

    if not ignore_mt then
        local mt1 = getmetatable(o1)
        if mt1 and mt1.__eq then
            --compare using built in method
            return o1 == o2
        end
    end

    local keySet = {}

    for key1, value1 in pairs(o1) do
        local value2 = o2[key1]
        if value2 == nil or table.equals(value1, value2, ignore_mt) == false then
            return false
        end
        keySet[key1] = true
    end

    for key2, _ in pairs(o2) do
        if not keySet[key2] then return false end
    end
    return true
end

integer = {}

--[[ Check if an integer/float value is between two values.

@param The integer to test
@param The beginning of the range
@param The end of the range
@return true when int is between to and from (int >= to and int <= from). false, otherwise

--]]
function integer.between(int, to, from)
    if int < to or int > from then
        return false
    end
    return true
end

--[[ Get the greatest common divisor of two numbers using the Euclidean method.

@param Numeric value 1
@param Numeric value 2
@return The GCD of the two numbers

--]]
function math.euclid(a, b)
    if b ~= 0 then
        return math.euclid(b, a % b)
    else
        return math.abs(a)
    end
end

--[[ Returns the common divisor for an array of arbitrary numbers.

@param table which contains a list of numbers to determine common divisor.
@return The GCD of all numbers

--]]
function table.euclid(table1)
    if #table1 == 1 then
        return table1[1]
    end

    local values = {}
    local result = nil
    while not result do
        if #table1 == 2 then
            result = math.euclid(table1[1], table1[2])
        else
            local p = table1[1]
            local n = table1[2]
            table.remove(table1, 1)
            table.remove(table1, 1)
            table.insert(table1, math.euclid(p, n))
        end
    end
    return result
end

--[[ Reverse order of ipairs

@param table to reverse values for
@return Reversed table

]]--
function ripairs(t)
  local function ripairs_it(t, i)
    i = i - 1
    local v = t[i]
    if v == nil then return v end
    return i, v
  end
  return ripairs_it, t, #t + 1
end

function get(value, default)
    return value or default
end
