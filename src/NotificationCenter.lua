--
-- Provides notification center which allows actors to broadcast messages
-- to observers.
--
-- @copyright (c) 2014 Upstart Illustration LLC. All rights reserved.
--

require "Logger"

local NotificationObserver = require("NotificationObserver")

local NotificationCenter = Class()

function NotificationCenter.new(self)
    local observers = {}

    -- @fixme I think it would be more appropriate to have a getObserversForEventID() method
    function self.getObservers()
        return observers
    end
    
    -- Add an observer for an event ID.
    function self.addObserver(observer, callback, eventId)
        if not observers[eventId] then
            observers[eventId] = {}
        end
        for _, obs in ipairs(observers[eventId]) do
            if obs.observer == observer then
                return -- Already listening.
            end
        end
        table.insert(observers[eventId], NotificationObserver(observer, callback))
    end

    -- Remove observer associated to event ID.
    function self.removeObserverForEvent(observer, eventId)
        -- There are no observers for this event.
        if not observers[eventId] then
            return
        end
        -- Remove observer from event list.
        local tObs = observers[eventId]
        for id, obs in ipairs(tObs) do
            if obs.observer == observer then
                table.remove(observers[eventId], id)
                return
            end
        end
    end

    -- Remove observer from all observing events.
    function self.removeObserver(observer)
        for eventId, _ in pairs(observers) do
            self.removeObserverForEvent(observer, eventId)
        end
    end

    -- Post event to all observers observing event ID.
    function self.postNotification(eventId, obj)
        -- Cleanup
        if observers[eventId] and #observers[eventId] < 1 then
            Log.d("Cleaned up eventId: ", eventId)
            observers[eventId] = nil
        end
        if not observers[eventId] then
            return
        end
        -- Inform all observers of event.
        for _, obs in ipairs(observers[eventId]) do
            obs.callback(obj)
        end
    end
end

return NotificationCenter
