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

    -- Removing leading zero.
    local function lz(num)
        local n = string.format("%u", tostring(num))
        if not n then assert(false, "number is nil") end
        --print("n", n)
        return tonumber(n)
    end

    -- Prepend current century to year.
    local function century(year)
        if string.len(year) >= 4 then
            return year
        end
        local century = string.sub(os.date("%Y"), 1, 2)
        return tonumber(century .. tostring(year))
    end

    function self.getDate()
        return date
    end

    local date_format = "(%d+) (%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)"
    function self.getEpoch()
        if not sucess then
            Log.w("NTP.Response.getEpoch: Attempting to get epoch when request failed. Returning current time.")
            return gettime()
        end
        local parts = string.split(date, " ")
        -- Take the first three parts of the date:
        -- 1. ms 2. YY-MM-DD 3. HH:MM:SS
        parts = table.slice(parts, 1, 3)
        local date_only = table.join(parts, " ")
        local ms, year, month, day, hour, minute, second, _, _, _, _, _ = date_only:match(date_format)
        local epoch = os.time({day=lz(day), month=lz(month), year=century(year), hour=lz(hour), min=lz(minute), sec=lz(second)})
        if not epoch then
            Log.w("NTP.Response.getEpoch: Failed to compute epoch for date (%s)", date_only)
            return gettime()
        end
        return epoch
    end

    function self.isSuccess()
        return success
    end

    function self.getError()
        return err
    end
end

return Response
