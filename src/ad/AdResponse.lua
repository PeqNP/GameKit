--
-- @copyright 2015 Upstart Illustration LLC. All rights reserved.
--

AdResponse = Class()

function AdResponse.new(self, id, succes, _error)
    function self.getId()
        return id
    end

    function self.getSuccess()
        return success
    end

    function self.getError()
        return _error
    end
end
