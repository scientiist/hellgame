local Sprite = {}

setmetatable(Sprite,{
    __index = Sprite,
    __tostring = function(a) return "Sprite" end,
    
})

function Sprite:new(imageSource, frameWidth)
    local img = love.graphics.newImage(imageSource)
    local x, y = img:getDimensions()
    local newSpr = {
        frames = {}
    }
    local slices = x/frameWidth

    for i = 1, slices do
        newSpr.frames[i] = love.graphics.newQuad(i-1, i-1, i*frameWidth, i*y, img:getDimensions())
    end

    return setmetatable(newSpr, getmetatable(self))
end

function Sprite:getFrame(index)
    return self.frames[index]
end

return Sprite