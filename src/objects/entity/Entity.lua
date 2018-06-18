local newclass = require("src.objects.yaci")

local Point = require("src.datatypes.Point")
local Rectangle = require("src.datatypes.Rectangle")

local Entity = newclass("Entity")

function Entity:init()
    self.position = Point:new(50, 50)
    self.body = Rectangle:new(-8, -8, 8, 8)
    self.collidesTiles = true
    self.collidesPlayer = false

    self.destroyWhenOffScreen = false

    self.markedForRemoval = false
end

function Entity:destroy()
    self.markedForRemoval = true
end

function Entity:getExtents()
    return Rectangle:new(
        self.body.x1+self.position.x,
        self.body.y1+self.position.y,
        self.body.x2+self.position.x,
        self.body.y2+self.position.y
    )
end

function Entity:isCollidingWith(otherEntity)
    return (self:getExtents()):overlaps(otherEntity:getExtents())
end


function Entity:update(delta)

end


function Entity:render()
    local renderX = self.position.x+self.body.x1
    local renderY = self.position.y+self.body.y1
    love.graphics.setColor(0.5, 0.5, 1)
    love.graphics.rectangle("line", renderX, renderY, self.body.x2, self.body.y2)
end


return Entity