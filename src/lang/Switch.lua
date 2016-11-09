--
-- Provides switch...case.
--
-- Notes:
-- The default case does not need to call 'break' and will not provide current context.
-- The default case will always terminate after being called, regardless of whether there
-- is a case created after it.
--
-- @copyright (c) 2016 Upstart Illustration LLC. All rights reserved.
-- 

local Switch = Class()
function Switch.new(self)
    local subject
    local complete
    local value
    local matched = false

    function self.init(s)
        subject = s
    end

    -- Add a case to switch on.
    function self.case(case, fn)
        if not complete and (matched or case == subject) then
            matched = true
            value = fn()
            if value then
                complete = true
            end
        end
        return self
    end

    -- Break
    function self.b()
        if matched then
            complete = true
        end
        return self
    end

    -- The default case called when no case has matched.
    function self.default(fn)
        if not complete then
            value = fn()
        end
        return self
    end

    -- Returns the value returned from a case statement.
    function self.value()
        return value
    end
end

function switch(value)
    return Switch(value)
end
