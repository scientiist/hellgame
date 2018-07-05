--| imports
    local Entity       = require("src.game.entity.Entity")
    local Rect         = require("src.datatypes.Rect")
    local Vector2D     = require("src.datatypes.Vector2D")
    local Sprite       = require("src.datatypes.Sprite")
--|
local Bullet = Entity:subclass("Bullet")
    Bullet.hasMass = false
    Bullet.sprite = Sprite:new("assets/image/sprite/bullet.png", 4)
    Bullet.body = Rect:new(0, 0, 2, 0.5)
    Bullet.speed = 6
    Bullet.destroyWhenOffScreen = true
    Bullet.destroyOnTileCollide = true


function Bullet:init(position, direction)
    self.super:init()
    self.position = position
    self.directionX = direction

    self.velocity = Vector2D:new(self.directionX*self.speed, math.random(-150, 150)/100)
end

return Bullet