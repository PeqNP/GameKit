--
-- Prints current time from NTP server.
--
-- @copyright (c) 2016 Upstart Illustration, LLC
--

require("lang.Signal")
require("Logger")

local NTPClient = require("ntp.Client")
local client = NTPClient()
response = client.requestTime()
Log.i("NTPResponse: date (%s) time (%s) success (%s) error (%s)", response.getDate(), response.getEpoch(), response.isSuccess(), response.getError())
os.exit(0)
