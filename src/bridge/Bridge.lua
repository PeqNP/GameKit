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

    function self.getAdaptor()
        return adaptor
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
