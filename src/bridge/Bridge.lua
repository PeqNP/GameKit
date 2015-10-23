--
-- @copyright 2015 Upstart Illustration LLC. All rights reserved.
--

require "Promise"

BridgeRequest = Class()
function BridgeRequest.new(self, request, promise)
    function self.getRequest()
        return request
    end
    function self.getPromise()
        return promise
    end
end

Bridge = Class()

function Bridge.new(self, adaptor)
    local requests = {}
    local modules = {}
    local registeredModules = {}

    function self.getAdaptor()
        return adaptor
    end

    function self.isModuleRegistered(module)
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
        if self.isModuleRegistered(moduleName) then
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
        local ok = adaptor.send(method, request.getMessage())
        if ok then
            local req = BridgeRequest(request, promise)
            table.insert(requests, req)
        else
            promise.reject(string.format("Failed to call method (%s)", method))
        end
        return promise
    end

    function self.receive(response)
    end
end
