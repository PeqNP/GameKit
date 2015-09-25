--[[
  Provides notification center which allows actors to broadcast messages
  to observers.

  @copyright 2014 Upstart Illustration LLC. All rights reserved.

--]]

--[[ NotificationObserver ]]--

NotificationObserver = Class()

function NotificationObserver.new(_observer, _callback)
    local self = {}
    self.observer = _observer
    self.callback = _callback
    return self
end

--[[ NotificationCenter ]]--

NotificationCenter = Class()
Singleton(NotificationCenter)

function NotificationCenter.new()
    local self = {}

    local _observers = {}
    
    --[[ Add observer for given event. ]]--
    function self.addObserver(observer, callback, eventId)
        --print("--->addObserver", tostring(observer), callback, eventId)
        if not _observers[eventId] then
            _observers[eventId] = {}
        end
        for _, obs in ipairs(_observers[eventId]) do
            if obs.observer == observer then
                --cclog("-> Aldready listening")
                return -- Already listening.
            end
        end
        table.insert(_observers[eventId], NotificationObserver(observer, callback))
        --print("-> # observers: "..#_observers[eventId])
    end

    function self.removeObserverForEvent(observer, eventId)
        --cclog("--->removeObserverForEvent: "..tostring(observer)..", eventId: "..eventId)
        -- There are no observers for this event.
        if not _observers[eventId] then
            return
        end
        -- Remove observer from event list.
        local tObs = _observers[eventId]
        for id, obs in ipairs(tObs) do
            --cclog("-> curr: "..tostring(observer).." obs: "..tostring(obs.observer))
            if obs.observer == observer then
                --cclog("->removeObserverForEvent removed! id: "..id)
                table.remove(_observers[eventId], id)
                --print("-> # left: "..#_observers[eventId])
                return
            end
        end
    end

    --[[ Remove observer from all observing events. ]]--
    function self.removeObserver(observer)
        --print("-->removeObserver:", tostring(observer))
        for eventId, _ in pairs(_observers) do
            self.removeObserverForEvent(observer, eventId)
        end
    end

    --[[ Post event to all observers observing eventId. ]]--
    function self.postNotification(eventId, obj)
        --cclog("-->postNotification: "..eventId)
        -- Cleanup
        if _observers[eventId] and #_observers[eventId] < 1 then
            cclog("Cleaned up eventId: "..tostring(eventId))
            _observers[eventId] = nil
        end
        if not _observers[eventId] then
            return
        end
        --cclog("-->postNotification: #"..#_observers[eventId])
        -- Inform all observers of event.
        for _, obs in ipairs(_observers[eventId]) do
            --print("calling:", tostring(obs), eventId)
            obs.callback(obj)
        end
    end

    return self
end
