require "lang.Signal"
require "busted"

require "NotificationCenter"

describe("NotificationCenter", function()
    local subject

    before_each(function()
        subject = NotificationCenter()
    end)

    it("should have no observers", function()
        local observers = subject.getObservers()
        assert.equals(0, #observers)
    end)

    context("when registering an observer", function()
        local observer
        local callback
        local eventId
        local called

        before_each(function()
            observer = {}
            called = false
            callback = function()
                called = true
            end
            eventId = "EVENT"
            subject.addObserver(observer, callback, eventId)
        end)

        it("should have registered observer", function()
            local observers = subject.getObservers()
            assert.truthy(observers[eventId])
            assert.equals(1, #observers[eventId])
            local obs = observers[eventId][1]
            assert.equals(observer, obs.observer)
            assert.equals(callback, obs.callback)
        end)

        it("should not yet have fired a notification", function()
            assert.falsy(called)
        end)

        context("when posting a notification", function()
            local caller

            before_each(function()
                caller = {}
                subject.postNotification(eventId, caller)
            end)

            it("should have posted a notification to our callback", function()
                assert.truthy(called)
            end)
        end)
    end)
end)
