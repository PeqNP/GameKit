--
-- @copyright 2015 Upstart Illustration LLC. All rights reserved.
--

require "Promise"
require "bridge.BridgeCall"

Bridge = Class()

function Bridge.new(self)
    local adaptor
    local private = {}
    local requests = {}
    local numRequests = 0
    local modules = {}
    local registeredModules = {}

    function self.init(_adaptor)
        adaptor = _adaptor
    end

    function self.getAdaptor()
        return adaptor
    end

    function self.getRequests()
        return requests
    end

    function self.getNumRequests()
        return numRequests
    end

    function private.isModuleRegistered(module)
        for _, registered in ipairs(registeredModules) do
            if module == registered then
                return true
            end
        end
        return false
    end

    --
    -- Load and register a module with the Bridge.
    --
    -- @param string - The name of the module path to load. Ex: 'bridge.modules.ad'
    --
    function self.registerModule(moduleName)
        if private.isModuleRegistered(moduleName) then
            return
        end
        local module = require(moduleName)
        module.init(self)
        table.insert(modules, module)
        table.insert(registeredModules, moduleName)
    end

    function self.getModules()
        return modules
    end

    function self.send(method, request, sig)
        return adaptor.send(method, request.toDict(), sig)
    end

    --
    -- @param str - native method name to execute.
    -- @param table - key/value pairs containig message to send.
    -- @param table - key/value pair indicating the types of parameters being sent.
    --
    -- @return Promise, mixed (response from native layer)
    --
    function self.sendAsync(method, request, sig)
        local response = adaptor.send(method, request.toDict(), sig)
        local req = BridgeCall(request)
        if response then
            if response.success then
                requests[tostring(response.id)] = req
                numRequests = numRequests + 1
            else
                req.reject(string.format("Response failed w/ error (%s)", response.error))
            end
        else
            req.reject(string.format("Failed to call method (%s)", method))
        end
        return response, req
    end

    function private.getRequestForResponse(response)
        local id = tostring(response.getId())
        local request = requests[id]
        if request then
            return id, request
        end
        return nil, nil
    end

    -- @param id<BridgeResponseProtocol>
    function self.receive(response)
        local id, request = private.getRequestForResponse(response)
        if not request then
            Log.e("Response (%s) no longer has corresponding request!", response.getId())
            return
        end
        requests[id] = nil
        numRequests = numRequests - 1
        request.resolve(response)
    end
end
