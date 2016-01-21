--
-- @copyright (c) 2016 Upstart Illustration LLC. All rights reserved.
--

local ServerConfig = Class()

function ServerConfig.new(self)
    local host
    local port
    local path

    function self.init(_host, _port, _path)
        host = _host
        port = _port
        path = _path
    end

    function self.getHost()
        return host
    end

    function self.getPort()
        return port
    end

    function self.getPath()
        return path
    end
end

return ServerConfig
