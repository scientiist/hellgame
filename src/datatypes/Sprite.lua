local LoveImage = require("src.datatypes.LoveImage")

local Sprite = {}

setmetatable(Sprite,{
    __index = Sprite,
    __tostring = function(a) return "Sprite" end,
    
})

function Sprite:new(imageSource, frameWidth, frameHeight)
    local img = LoveImage:new(imageSource)
    local x, y = img:getDimensions()

    frameWidth = frameWidth or x
    frameHeight = frameHeight or y

    local xslices = x/frameWidth
    local yslices = y/frameHeight
    local newSpr = {
        frames = {},
        image = img,
        width = frameWidth,
        height = y
    }

    local i = 1
    for y = 1, yslices do
        for x = 1, xslices do
            
            newSpr.frames[i] = love.graphics.newQuad((x-1)*frameWidth, (y-1)*frameHeight, frameWidth, frameHeight, img:getDimensions())
            i = i + 1
        end
    end

    return setmetatable(newSpr, getmetatable(self))
end

function Sprite:getFrame(index)
    return self.frames[index] or self.frames[1]
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