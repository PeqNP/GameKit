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
