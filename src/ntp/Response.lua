--
-- @copyright (c) 2016 Upstart Illustration, LLC
--

local Response = Class()

function Response.new(self)
    local date
    local success
    local err

    function self.init(d, s, e)
        date = d
        success = s
        err = e
    end

    function self.getDate()
        return date
    end

    function self.getEpochTime()
        -- TODO:
        return date
    end

    function self.isSuccess()
        return success
    end

    function self.getError()
        return err
    end
end

return Response
