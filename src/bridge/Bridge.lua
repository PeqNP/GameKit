--
-- Provides interface to communicate between native and script environment.
--
-- @copyright 2015 Upstart Illustration LLC. All rights reserved.
--

local BridgeCall = require("bridge.BridgeCall")

local Bridge = Class()

function Bridge.new(self)
    local adaptor -- BridgeAdaptor
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
        local payload = request and request.toDict() or nil
        return adaptor.send(method, payload, sig)
    end

    --
    -- @param str - native method name to execute.
    -- @param table - key/value pairs containig message to send.
    -- @param table - key/value pair indicating the types of parameters being sent.
    --
    -- @return Promise, mixed (response from native layer)
    --
    function self.sendAsync(method, request, sig)
        local response
        if request then
            response = adaptor.send(method, request.toDict(), sig)
        else
            response = adaptor.send(method)
        end
        -- @todo response will be a number value when an exception happened in native land.
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

    -- @param id<BridgeResponseProtocol>
    function self.receive(response)
        local id = tostring(response.getId())
        local request = requests[id]
        if not request then
            Log.e("Response (%s) no longer has corresponding request!", id)
            return
        end
        requests[id] = nil
        numRequests = numRequests - 1
        if not response.isSuccess or response.isSuccess() then
            request.resolve(response)
        else
            request.reject(response)
        end
    end
end

return Bridge
