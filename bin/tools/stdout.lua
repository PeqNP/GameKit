
stdout = {}

function stdout.r(msg)
    io.write("\r" .. msg)
    io.flush()
end
