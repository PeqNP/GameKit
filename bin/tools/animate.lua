--[[ Creates an animated gif.

Will create a looping animated gif with a 10 millisecond delay.
$ lua animate.lua /path/to/my-gif-[without numbers or extension] /path/to/animated.gif 1 31 10

--]]

function convert_to_gifs(source, start_frame, end_frame)
    print("Flattening images...")
    for frame=start_frame,end_frame do
        local cmd = string.format("convert -flatten -background white '%s%02d.png' '%s%02d-flattened.png'", source, frame, source, frame)
        os.execute(cmd)
    end
    print("Converting PNGs to GIFs...")
    for frame=start_frame,end_frame do
        local cmd = string.format("convert '%s%02d-flattened.png' '%s%02d.gif'", source, frame, source, frame)
        os.execute(cmd)

        local cmd = string.format("rm '%s%02d-flattened.png'", source, frame)
        os.execute(cmd)
    end
end

function create_animated_gif(source, target, start_frame, end_frame, delay, loop)
    loop = loop and "--loop" or ""
    local gifs = ""
    for frame=start_frame,end_frame do
        gifs = gifs .. string.format(" %s%02d.gif", source, frame)
    end
    local cmd = string.format("gifsicle --colors 256 --delay=%d %s %s > %s", delay, loop, gifs, target)
    print(cmd)
    os.execute(cmd)
end

-- CLI Args

local source = arg[1]
local target = arg[2]
local start_frame = tonumber(arg[3])
local end_frame = tonumber(arg[4])
local delay = tonumber(arg[5])

--convert_to_gifs(source, start_frame, end_frame)
create_animated_gif(source, target, start_frame, end_frame, delay, true)
