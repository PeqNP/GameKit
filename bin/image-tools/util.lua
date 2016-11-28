
local util = {}

--[[
  Returns the number of characters which represent the number 'N'.

  ```
  util.get_char_size(1) -- returns 1
  util.get_char_size(20) -- returns 2
  util.get_char_size(101) -- returns 3
  ```

  ]]
function util.get_char_size(N)
    if N < 2 then
        N = 2
    end
    return string.len(tostring(N))
end

--[[
  Returns a list of files within 'directory'.

  ]]
function util.get_files(directory)
    local files = {}
    local pfile = io.popen('ls -a "'..directory..'"')
    for filename in pfile:lines() do
        if filename ~= "." and filename ~= ".." then
            table.insert(files, filename)
        end
    end
    pfile:close()
    return files
end

return util
