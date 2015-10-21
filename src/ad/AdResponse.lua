--
-- @copyright 2015 Upstart Illustration LLC. All rights reserved.
--

AdResponse = Class()

function AdResponse.new(self, id, state, _error)
    function self.getId()
        return id
    end

    function self.getState()
        return state
    end

    function self.getError()
        return _error
    end
end
