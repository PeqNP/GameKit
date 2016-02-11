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
    for key, fn in ipairs(protocol) do
        mock[key] = fn
    end
    return mock
end
