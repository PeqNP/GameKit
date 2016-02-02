--
-- @copyright (c) 2015 Upstart Illustration LLC. All rights reserved.
-- @attribution Inspired by https://github.com/friesencr/lua_promise
-- @license <http://unlicense.org/>
--

local Promise = Class()

local function null_or_unpack(val)
    if val then
        return unpack(val)
    else
        return nil
    end
end

function Promise.new(self)
    local _state = "pending"
    local _callbacks = {}
    local _value = false

    self.is_deferred = true

    --
    -- server functions
    --

    function self.reject(...)
        local arg = {...}
        assert(_state == 'pending', "Trying to resolve a promise that has already been resolved")
        _value = arg
        _state = 'rejected'

        for i,v in ipairs(_callbacks) do
            if v.event == 'always' or v.event == 'fail' then
                v.callback(null_or_unpack(arg))
            end
        end
        _callbacks = {}
    end

    function self.resolve(...)
        local arg = {...}
        assert(_state == 'pending', "Trying to resolve a promise that has already been resolved")
        _value = arg
        _state = 'resolved'

        for i,v in ipairs(_callbacks) do
            if v.event == 'always' or v.event == 'done' then
                v.callback(null_or_unpack(arg))
            end
        end
        _callbacks = {}
    end

    function self.notify(...)
        local arg = {...}
        assert(_state == 'pending', "Trying to resolve a promise that has already been resolved")
        for i,v in ipairs(_callbacks) do
            if v.event == 'progress' then
                v.callback(null_or_unpack(arg))
            end
        end
    end

    --
    -- client function
    --

    function self.always(callback)
        if _state ~= 'pending' then
            callback(null_or_unpack(_value))
        else
            table.insert(_callbacks, { event = 'always', callback = callback })
        end
        return self
    end

    function self.done(callback)
        if _state == 'resolved' then
            callback(null_or_unpack(_value))
        elseif _state == 'pending' then
            table.insert(_callbacks, { event = 'done', callback = callback })
        end
        return self
    end

    function self.fail(callback)
        if _state == 'rejected' then
            callback(null_or_unpack(_value))
        elseif _state == 'pending' then
            table.insert(_callbacks, { event = 'fail', callback = callback })
        end
        return self
    end

    function self.progress(callback)
        if _state == 'pending' then
            table.insert(_callbacks, { event = 'progress', callback = callback })
        end
        return self
    end

    --
    -- utility functions
    --

    function self.getState()
        return _state
    end

    function self.isComplete()
        return table.contains({"rejected", "resolved"}, _state)
    end
end

function Promise.when(...)
    local arg = {...}
    local deferred = Promise()
    local returns = {}
    local total = # arg
    local completed = 0
    local failed = 0
    check = function()
        if completed == total then
            if failed > 0 then
                deferred.reject(null_or_unpack(returns))
            else
                deferred.resolve(null_or_unpack(returns))
            end
        end
    end
    for i,v in ipairs(arg) do
        if (v and type(v) == 'table' and v.is_deferred) then
            local promise = v
            v.always(function(val)
                if promise.getState() == 'rejected' then
                    failed = failed + 1
                end
                completed = completed + 1
                returns[i] = val
                check()
            end)
        else
            returns[i] = v
            completed = completed + 1
        end
        check()
    end
    return deferred
end

return Promise
