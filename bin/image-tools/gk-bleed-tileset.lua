#!/usr/local/bin/lua
--[[ Bleeds tilesets by adding 2 pixel boundary around each tile and composes
  the tiles back in the same order.

  With 32x32, this creates a 38x40 tile... adding 3p on X and 4p on Y
  
  @copyright ???
  ]]

function TilesetBleeder ( inputfile, imgwidth, imgheight, tilewidth, tileheight, columns, rows )
    local img_in = MOAIImage.new ()
    img_in:load ( inputfile )

    local img_out = MOAIImage.new ()
    img_out:init ( imgwidth, imgheight )

    for r = 0, rows - 1 do
        for c = 0, columns - 1 do
            local srcx = c*tilewidth
            local srcy = r*tileheight
            local dstx = 1 + srcx + ( 2 * c )
            local dsty = 1 + srcy + ( 2 * r )
            img_out:copyBits ( img_in, srcx, srcy, dstx, dsty, tilewidth, tileheight )
            img_out:bleedRect ( dstx, dsty, dstx+tilewidth, dsty+tileheight )
        end
    end

    return img_out
end

out = TilesetBleeder ( "/Users/eric/git/sjw/res/level/forest/props-normal.png", 544, 544, 32, 32, 16, 16 )

out:writePNG ( "props-normal.png" )
