
function fn2(self, ...)
    print(self)
    local arg = {...}
    for _, val in ipairs(arg) do
        print("fn2", val)
    end
end

function fn(...)
    local arg = {...}
    for _, val in ipairs(arg) do
        print("val", _, val)
    end
    fn2("you", ...)
end

fn("Here", "There")
os.exit(0)

function param(p)
    p = {"error"}
end

param()

local pin = {}
param(pin)
print("pin", pin[1])
os.exit(0)

local t = {} == {}
print(tostring(t))
local t = {}
local t = t == t
print(tostring(t))
os.exit(0)

local args = nil
function a(...)
    args = {...}
end

a("hi", "there")
print(args[1], args[2])

--[[
local t = {1, 2, 3}
-- 'in' is used only for 'for' loops.
if 1 in t then
    print("1 is in t!")
end
--]]
