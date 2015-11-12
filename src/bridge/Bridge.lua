--
-- @copyright 2015 Upstart Illustration LLC. All rights reserved.
--

require "Promise"

BridgeCall = Class()
function BridgeCall.new(self)
    local request
    local promise

    function self.init(_request, _promise)
        request = _request
        promise = _promise
    end

    function self.getId()
        return request.getId()
    end
    function self.getRequest()
        return request
    end
    function self.getPromise()
        return promise
    end
end

Bridge = Class()

function Bridge.new(self)
    local adaptor
    local private = {}
    local requests = {}
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

    -- @return Promise
    function self.send(method, request, sig)
        local promise = Promise()
        local ok = adaptor.send(method, request.getMessage(), sig)
        if ok then
            local req = BridgeCall(request, promise)
            table.insert(requests, req)
        else
            promise.reject(string.format("Failed to call method (%s)", method))
        end
        return promise
    end

    function private.getRequestForResponse(response)
        for idx, request in ipairs(requests) do
            if request.getId() == response.getId() then
                return idx, request
            end
        end
        return nil, nil
    end

    -- @param id<BridgeResponseProtocol>
    function self.receive(response)
        local idx, request = private.getRequestForResponse(response)
        if not request then
            Log.e("Response (%s) no longer has corresponding request!", response.getId())
            return
        end
        request.getPromise().resolve(response)
        table.remove(requests, idx)
    end
end
