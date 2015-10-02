--[[
  Gesture recognition.

  @todo Unregister touches from layer when Exit called. OR
        unregister previously listening to layer from Start. (Call Exit)

  @copyright 2015 Upstart Illustration LLC. All rights reserved.

--]]

require "Constants"
require "Logger"

require "gesture.LongPressGesture"
require "gesture.TapGesture"
require "gesture.SwipeGesture"

local V = {}

----------------------------------------------------------------
-- Variables
----------------------------------------------------------------

V.PI = 4 * math.atan(1)
V.PI2 = 2 * V.PI
V.points = {}
V.anglesMap = {}
V.recording = false
V.tolerance = 20
V.minimumLinePoints = 2
V.finalResult = 0

V.touchBeganTime = false
V.isLongPress = false
V.swipeMinDuration = 0.22

-- Executed when gesture is complete.
V.longPressCallback = false
V.tapCallback = false
V.swipeCallback = false

Log.d("Gesture: Ready!")

----------------------------------------------------------------
-- Touch Patterns
----------------------------------------------------------------

--[[
  Types of gestures:

  + Tap
  + LongPress
  + Swipe (w/ direction)

  @todo Make certain gestures occur only after a certain period of time
  has elapsed, such as with swipes.

  Not implemented:

  + Pinch
  + Rotate
  + EdgeSwipe
  + Shape
--]]

V.gestures = {
    "0",
    "4",
    "2",
    "6",
    "0246",
    "2064",
    "0642",
    "2460",
    "4206",
}

V.gestureSigns = {
    "SwipeR",
    "SwipeL",
    "SwipeU",
    "SwipeD",
    "Square",
    "Square",
    "Square",
    "Square",
    "Square",
}

--[[ Find distance between two points. ]]--
local function Distance(u, v)
    local x = u.x - v.x
    local y = u.y - v.y
    return math.sqrt((x*x) + (y*y))
end

--[[ Find minimum moves using levenshtein. ]]--
local function Levenshtein(s, t)
    local d, sn, tn = {}, #s, #t
    local byte, min = string.byte, math.min
    for i = 0, sn do d[i * tn] = i end
    for j = 0, tn do d[j] = j end
    for i = 1, sn do
        local si = byte(s, i)
        for j = 1, tn do
            d[i*tn+j] = min(d[(i-1)*tn+j]+1, d[i*tn+j-1]+1, d[(i-1)*tn+j-1]+(si == byte(t,j) and 0 or 1))
        end
    end
    return d[#d]
end

--[[ Degrees to sector table. ]]--
local function DegreesToSector(x1,y1,x2,y2)
    local a1 = x2 - x1
    local b1 = y2 - y1
    local radians = math.atan2(a1, b1)
    local degrees = radians / (V.PI / 180)
    local degreesBack = degrees - 90

    --[[
      Sectors:

      0: 22 ,-23
      1: -24, -59
      2: -60, -105
      3: -106, -150
      4: -151, -196
      5: -197, -241
      6: -242, 63
      7: 23, 62

    ]]--

    if degreesBack < 22 and degreesBack > -23 then
         if V.anglesMap[table.maxn(V.anglesMap)] ~= 0 then
            table.insert(V.anglesMap, 0)
        end
    elseif degreesBack < -24 and degreesBack > -59 then
        if V.anglesMap[table.maxn(V.anglesMap)] ~= 1 then
            table.insert(V.anglesMap, 1)
        end
    elseif degreesBack < -60 and degreesBack > -105 then
        if V.anglesMap[table.maxn(V.anglesMap)] ~= 2 then
            table.insert(V.anglesMap, 2)
        end
    elseif degreesBack < -106 and degreesBack > -150 then
        if V.anglesMap[table.maxn(V.anglesMap)] ~= 3 then
            table.insert(V.anglesMap, 3)
        end
    elseif degreesBack < -151 and degreesBack > -196 then
        if V.anglesMap[table.maxn(V.anglesMap)] ~= 4 then
            table.insert(V.anglesMap, 4)
        end
    elseif degreesBack < -197 and degreesBack > -241 then
        if V.anglesMap[table.maxn(V.anglesMap)] ~= 5 then
            table.insert(V.anglesMap , 5)
        end
    elseif degreesBack > 60 and degreesBack > -242 then
        if V.anglesMap[table.maxn(V.anglesMap)] ~= 6 then
            table.insert(V.anglesMap , 6)
        end
    elseif degreesBack < 62 and degreesBack > 23 then
        if V.anglesMap[table.maxn(V.anglesMap)] ~= 7 then
            table.insert(V.anglesMap , 7)
        end
    end
end

----------------------------------------------------------------
-- Utility functions
----------------------------------------------------------------

local function ValToStr(v)
    if "string" == type(v) then
        v = string.gsub(v, "\n", "\\n")
        if string.match(string.gsub(v,"[^'\"]",""), '^"+$') then
            return "'" .. v .. "'"
        end
        return '"' .. string.gsub(v,'"', '\\"' ) .. '"'
    end
    return "table" == type( v ) and table.tostring( v ) or tostring( v )
end

local function KeyToStr(k)
    if "string" == type(k) and string.match(k, "^[_%a][_%a%d]*$") then
        return k
    else
        return "[" .. ValToStr( k ) .. "]"
    end
end

local function TableToStr(tbl)
    local result, done = {}, {}
    for k, v in ipairs(tbl) do
        table.insert(result, ValToStr(v))
        done[ k ] = true
    end
    for k, v in pairs( tbl ) do
        if not done[ k ] then
            table.insert(result, KeyToStr(k) .. "=" .. ValToStr(v))
        end
    end
    return table.concat(result)
    --table.concat( result, "," )
end

local function LowPointsToMatch()
     local numPoints = #V.points
     local nl = {}
     local j, p
     local patternArray = {}

     nl[1] = V.points[1]

     j = 2
     p = 1

     for i = 2, numPoints, 1 do
          if Distance(V.points[i], V.points[p]) < V.tolerance then
          else
             nl[j] = V.points[i]
             j = j+1
             p = i
          end
     end

     if p < numPoints - 1 then
        nl[j] = V.points[numPoints - 1]
     end

     if #nl > 2 then
        DegreesToSector(nl[1].x,nl[1].y,nl[2].x,nl[2].y)
        for i = 3, #nl, 1 do
            DegreesToSector(nl[i-1].x,nl[i-1].y,nl[i].x,nl[i].y)
        end
    end
end

----------------------------------------------------------------
-- Touch events
----------------------------------------------------------------

local function OnTouchBegan(touch, event)
    V.touchBeganTime = gettime()
    local pt = touch:getLocation()
    pt.time = gettime()
    table.insert(V.points, pt)
    return true
end

local function OnTouchMoved(touch, event)
    local pt = touch:getLocation()
    pt.time = gettime()

    if V.longPressCallback then
        if V.isLongPress then
            V.longPressCallback(LongPressGesture(pt, V.points[#V.points], Touch.Moved))
        else
            Log.d("Is long press...")
            V.isLongPress = true
            V.longPressCallback(LongPressGesture(pt, pt, Touch.Began))
        end
    end

    table.insert(V.points, pt)
    V.recording = true
end

local function OnTouchEnded(touch, event)
    V.recording = false
    LowPointsToMatch()
    local gestureId
    local gestureValue
    --[[ Debugging
    if V.anglesMap then
        Log.d("anglesMap: %s", TableToStr(V.anglesMap))
    end
    --]]
    for i = 1, #V.gestures do
        if gestureId == nil then
            gestureId = i
            gestureValue = Levenshtein(TableToStr(V.anglesMap), V.gestures[i])
        elseif gestureValue > Levenshtein(TableToStr(V.anglesMap), V.gestures[i]) then
            gestureId = i
            gestureValue = Levenshtein(TableToStr(V.anglesMap), V.gestures[i])
        end
    end

    if #V.points >= V.minimumLinePoints then
        Log.d("Line points")
        -- Swipe gesture.
        if V.swipeCallback and gettime() - V.touchBeganTime < V.swipeMinDuration then
            local sign = V.gestureSigns[gestureId]
            if sign == "SwipeL" then
                V.swipeCallback(SwipeGesture(V.points[1], V.points[#V.points], Direction.Left))
            elseif sign == "SwipeR" then
                V.swipeCallback(SwipeGesture(V.points[1], V.points[#V.points], Direction.Right))
            elseif sign == "SwipeU" then
                V.swipeCallback(SwipeGesture(V.points[1], V.points[#V.points], Direction.Up))
            elseif sign == "SwipeD" then
                V.swipeCallback(SwipeGesture(V.points[1], V.points[#V.points], Direction.Down))
            end
        end

        -- Long press gesture.
        if V.isLongPress then
            if V.longPressCallback then
                V.longPressCallback(LongPressGesture(V.points[#V.points], V.points[#V.points], Touch.Ended))
            end
        end
    elseif V.tapCallback then
        V.tapCallback(TapGesture(V.points[1]))
    end

    V.isLongPress = false
    V.points = {}
    V.anglesMap = {}
end

--[[ Start recording touches on a given layer. ]]--
local function Start(layer, tapCallback, swipeCallback, longPressCallback)
    -- @fixme Stop listening to any previous layer.
    local eventDispatcher = layer:getEventDispatcher()
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:registerScriptHandler(OnTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(OnTouchMoved, cc.Handler.EVENT_TOUCH_MOVED)
    listener:registerScriptHandler(OnTouchEnded, cc.Handler.EVENT_TOUCH_ENDED)
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, layer)
    V.swipeCallback = swipeCallback
    V.tapCallback = tapCallback
    V.longPressCallback = longPressCallback
end
V.Start = Start

local function Stop()

    --Runtime:removeEventListener( "touch", Start )
    -- @todo unregister gesture.

    -- RESET ACCUMULATED FREEZE-TIME
    V.gLostTime               = 0
    V.points = nil
    V.points = {}
    V.anglesMap = nil
    V.anglesMap = {}

    collectgarbage("collect")

    Log.d("Gesture.Exit(): Finished.")
end
V.Stop = Stop

return V
