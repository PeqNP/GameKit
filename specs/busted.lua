--
-- Extensions for busted
--

context = describe

function pending_test(description, fn)
end

xdescribe = pending_test
xcontext = pending_test
xit = pending_test
