--
-- Extensions for busted
--

context = describe

function pending_test(description, fn)
end

xdescribe = pending_test
xcontext = pending_test
xit = pending_test

function mock_protocol(protocol)
    local mock = {}
    for _, method in ipairs(protocol.getMethods()) do
        mock[method.getName()] = function () end
    end
    return mock
end

--[[
  Creates a nice fake.

  When creating a fake, it does not contain methods created by Signal. This could be done
  by exposing the `alloc` method, whereby the instance could be created as it normally would
  by Signal, but intercepted before the `init` instance method is called.

  ]]
function nice_fake(class)
    local fake = {}
    local stub = {}
    class.new(fake)
    for method in pairs(fake) do
        stub[ method ] = function() end
    end 
    return stub
end
