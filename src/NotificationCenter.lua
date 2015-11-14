--[[
  Provides notification center which allows actors to broadcast messages
  to observers.

  @copyright 2014 Upstart Illustration LLC. All rights reserved.

--]]

require "NotificationObserver"

NotificationCenter = Class()

local shared = nil
function NotificationCenter.getInstance()
    if not shared then
        shared = NotificationCenter()
    end
    return shared
end

function NotificationCenter.new(self)
    local observers = {}

    -- @fixme I think it would be more appropriate to have a getObserversForEventID() method
    function self.getObservers()
        return observers
    end
    
    --[[ Add observer for given event. ]]--
    function self.addObserver(observer, callback, eventId)
        --print("--->addObserver", tostring(observer), callback, eventId)
        if not observers[eventId] then
            observers[eventId] = {}
        end
        for _, obs in ipairs(observers[eventId]) do
            if obs.observer == observer then
                --cclog("-> Aldready listening")
                return -- Already listening.
            end
        end
        table.insert(observers[eventId], NotificationObserver(observer, callback))
        --print("-> # observers: "..#observers[eventId])
    end

    function self.removeObserverForEvent(observer, eventId)
        --cclog("--->removeObserverForEvent: "..tostring(observer)..", eventId: "..eventId)
        -- There are no observers for this event.
        if not observers[eventId] then
            return
        end
        -- Remove observer from event list.
        local tObs = observers[eventId]
        for id, obs in ipairs(tObs) do
            --cclog("-> curr: "..tostring(observer).." obs: "..tostring(obs.observer))
            if obs.observer == observer then
                --cclog("->removeObserverForEvent removed! id: "..id)
                table.remove(observers[eventId], id)
                --print("-> # left: "..#observers[eventId])
                return
            end
        end
    end

    --[[ Remove observer from all observing events. ]]--
    function self.removeObserver(observer)
        --print("-->removeObserver:", tostring(observer))
        for eventId, _ in pairs(observers) do
            self.removeObserverForEvent(observer, eventId)
        end
    end

    --[[ Post event to all observers observing eventId. ]]--
    function self.postNotification(eventId, obj)
        --cclog("-->postNotification: "..eventId)
        -- Cleanup
        if observers[eventId] and #observers[eventId] < 1 then
            cclog("Cleaned up eventId: "..tostring(eventId))
            observers[eventId] = nil
        end
        if not observers[eventId] then
            return
        end
        --cclog("-->postNotification: #"..#observers[eventId])
        -- Inform all observers of event.
        for _, obs in ipairs(observers[eventId]) do
            --print("calling:", tostring(obs), eventId)
            obs.callback(obj)
        end
    end
end
