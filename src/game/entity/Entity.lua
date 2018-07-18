--| imports
    local Yaci     = require("src.libs.Yaci")
    local Rect     = require("src.datatypes.Rect")
    local Vector2D = require("src.datatypes.Vector2D")
    local Sprite   = require("src.datatypes.Sprite")
--|

--[[
    Entity class


--]]

local Entity = Yaci:newclass("Entity")
    Entity.body = Rect:new(0, 0, 8, 8)
    Entity.sprite = Sprite:new("assets/image/sprite/smiley.png", 8)
    Entity.collidesTiles = true
    Entity.collidesPlayer = false
    Entity.hasMass = false
    Entity.pauseWhenOffScreen = false
    Entity.destroyWhenOffScreen = false
    Entity.destroyOnTileCollide = false

function Entity:init()
    self.position = Vector2D:new(50, 50)
    self.nextPosition = Vector2D:new(0, 0)
    self.directionX = 1
    self.directionY = 1
    self.spriteFrame = 1
    self.velocity = Vector2D:new(0, 0)
    self.isTouchingGround = false
    self.markedForRemoval = false
    self.world = nil
    
end

function Entity:getExtents()
    return (self.body):addVec(self.position)
end

function Entity:collisionTileCallback(tileID, normalX, normalY)

end

function Entity:setPosition(pos)
    self.position = pos
end

function Entity:getNextFrameExtents()
    return (self.body):addVec(self.position + self.nextPosition)
end

function Entity:clean()
    self.markedForRemoval = true
end

function Entity:getPosition()
    return self.position
end

function Entity:update(delta)
    self.position = self.position + self.nextPosition


    self.nextPosition = Vector2D:new(self.velocity.x, self.velocity.y)
end


function Entity:render()
    local renderX = self.position.x-self.body.halfWidth
    local renderY = self.position.y-self.body.halfHeight
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(self.sprite:getImage(), self.sprite:getFrame(self.spriteFrame), self.position.x, self.position.y, 0, self.directionX, self.directionY, self.sprite:getWidth()/2, self.sprite:getHeight()/2)
    --love.graphics.rectangle("line", renderX, renderY, self.body.x2, self.body.y2)
    if self.world.debug then
        love.graphics.setLineWidth(0)
        love.graphics.setColor(1, 0.5, 0)
        love.graphics.rectangle("line", renderX, renderY, self.body.halfWidth*2, self.body.halfHeight*2)
    end

end


return Entity