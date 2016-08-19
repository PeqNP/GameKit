--
-- @copyright (c) 2016 Upstart Illustration, LLC
--

local NTPResponse = require("ntp.Response")

local Client = Class()

local TIME_SERVER_HOST = "time.nist.gov"
local TIME_SERVER_PORT = 13

-- 0.north-america.pool.ntp.org
-- us.pool.ntp.org

function Client.new(self)
    local host
    local port

    function self.init(h, p)
        host = h or TIME_SERVER_HOST
        port = p or TIME_SERVER_PORT
    end

    function self.requestTime()
        local client, err = socket.tcp()
        if err then
            return NTPResponse(nil, false, "Could not create TCP socket: " .. err)
        end

        Log.i("NTP.client.requestTime: Connecting to NTP @ %s:%s", host, port)

        client:settimeout(2.0, "t")
        client:connect(host, port)
        
        --[[ Where is the 'err' coming from?
        if err then
            return NTPResponse(nil, false, "Could not connect: "..err)
        end
        ]]--
        
        local _, err = client:send("\n")

        if err then
            return NTPResponse(nil, false, "Error in sending: " .. err)
        end
        
        -- KMW: need to rx a line, otherwise error.
        local _, _ = client:receive('*l')
        local line, err = client:receive('*l')
        client:close()

        if err then
            return NTPResponse(nil, false, "Error in receiving: " .. err)
        end
        
        if string.find(line, "UTC") then
            return NTPResponse(line, true, nil)
        end

        return NTPResponse(nil, false, "Bad result from server: " .. err)
    end
end

return Client
