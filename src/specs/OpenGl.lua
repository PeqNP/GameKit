
gl = {}

require "OpenGlConstants"

local texId = -1
function gl._getUniformLocation(prog, tex)
    texId = texId + 1
    return texId
end

function gl.activeTexture(tex)
end

function gl._bindTexture(tex, name)
end
