--
-- @copyright (c) 2016 Upstart Illustration, LLC
--

local Client = Class()

-- 0.north-america.pool.ntp.org
-- us.pool.ntp.org

function Client.new(self)
    local host
    local port

    function self.init(h, p)
        host = h or "us.pool.ntp.org"
        port = p or 13
    end

    function self.requestTime()
        local timeserver, err = socket.tcp()
        if err then
            return NTPResponse(nil, false, "Could not create TCP socket: "..err)
        end

        timeserver:settimeout(0.10, "t")
        timeserver:connect(host, port)
        timeserver:settimeout(0.10, "t")
        
        --[[ Where is the 'err' coming from?
        if err then
            return NTPResponse(nil, false, "Could not connect: "..err)
        end
        ]]--
        
        local _, err = timeserver:send("\n")

        if err then
            return NTPResponse(nil, false, "Error in sending: "..err)
        end
        
        -- KMW: need to rx a line, otherwise error.
        local _, _ = timeserver:receive('*l')
        local line, err = timeserver:receive('*l')

        if err then
            return NTPResponse(nil, false, "Error in receiving: "..err)
        end
        
        if string.find(line, "UTC") then
            return NTPResponse(line, true, nil)
        end

        return NTPResponse(nil, false, "Bad result from server: "..err)
    end
end

return Client
