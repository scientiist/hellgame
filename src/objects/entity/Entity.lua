local Point = require("src.datatypes.Point")
local Rectangle = require("src.datatypes.Rectangle")
local Vector2D = require("src.datatypes.Vector2D")

local Assets = require("src.game.Assets")

local newclass = require("src.objects.yaci")

local Entity = newclass("Entity") 

function Entity:init()
    self.position = Point:new(50, 50)
    self.body = Rectangle:new(-8, -8, 8, 8)
    self.directionX = 1
    self.directionY = 1
    self.collidesTiles = true
    self.collidesPlayer = false
    self.spriteFrame = 1
    self.velocity = Vector2D:new(0, 0)
    self.touchingGround = false

    
    self.sprite = Assets.sprites["player"]

    self.destroyWhenOffScreen = false
    self.markedForRemoval = false
    self.pauseWhenOffScreen = false
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
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(self.sprite:getImage(), self.sprite:getFrame(self.spriteFrame), self.position.x, self.position.y, 0, self.directionX, self.directionY, self.sprite:getWidth()/2, self.sprite:getHeight()/2)
    --love.graphics.rectangle("line", renderX, renderY, self.body.x2, self.body.y2)
    love.graphics.setLineWidth(0)
    love.graphics.setColor(1, 0.5, 0)
    love.graphics.rectangle("line", self.position.x+self.body.x1, self.position.y+self.body.y1, self.body.x2-self.body.x1, self.body.y2-self.body.y1)
    love.graphics.setColor(1, 0, 0)
    
    love.graphics.line(self.position.x, self.position.y, self.position.x+self.velocity.x, self.position.y+self.velocity.y)
end


return Entity