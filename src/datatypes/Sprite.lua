local AssetLoader = require("src.utils.AssetLoader")

local Sprite = {}

setmetatable(Sprite,{
    __index = Sprite,
    __tostring = function(a) return "Sprite" end,
    
})

function Sprite:new(imageSource, frameWidth)
    local img = AssetLoader:loadImage(imageSource)
    local x, y = img:getDimensions()
    local slices = x/frameWidth
    local newSpr = {
        frames = {},
        image = img,
        width = frameWidth,
        height = y
    }

    for i = 1, slices do
        newSpr.frames[i] = love.graphics.newQuad((i-1)*frameWidth+(i-1), 0, frameWidth, y, img:getDimensions())
    end

    return setmetatable(newSpr, getmetatable(self))
end

function Sprite:getFrame(index)
    return self.frames[index]
end

function Sprite:getImage()
    return self.image
end

function Sprite:getWidth()
    return self.width
end

function Sprite:getHeight()
    return self.height
end

return Sprite