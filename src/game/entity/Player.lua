--[[

--]]

--| imports
    local LivingEntity = require("src.game.entity.LivingEntity")
    local Rect         = require("src.datatypes.Rect")
    local Vector2D     = require("src.datatypes.Vector2D")
    local Sprite       = require("src.datatypes.Sprite")
    local Bullet       = require("src.game.entity.Bullet")
--|

local Player = LivingEntity:subclass("Player")
    Player.hasMass = true
    Player.sprite = Sprite:new("assets/image/sprite/player.png", 16)
    Player.body = Rect:new(0, 0, 4, 12)

function Player:init()
    
    self.super:init()
    self.isMoving = false
    self.deltaTracker = 0
    self.nextFramePos = self.position
    self.canShoot = true
    self.shootWait = 0
end

function Player:animation(delta)
    if self.isMoving then

        if self.deltaTracker > (1/20) then
            self.deltaTracker = 0
            self.spriteFrame = self.spriteFrame+1
            self.spriteFrame = (self.spriteFrame<=4) and self.spriteFrame or 2
        end
    else
        self.spriteFrame = 1
    end

    self.shootWait = self.shootWait - 0.1
end

function Player:update(delta)
    self.super:update(delta)


    self.deltaTracker = self.deltaTracker + delta
    self.isMoving = false
    self.velocity.x = 0
    if love.keyboard.isDown("left") then
        self.isMoving = true
        self.directionX = -1
        --self.position = self.position + Point:new(-1.5, 0)
        self.velocity = Vector2D:new(-1.75, self.velocity.y)
    end

    if love.keyboard.isDown("right") then
        self.isMoving = true
        self.directionX = 1
       --self.position = self.position + Point:new(1.5, 0)
       self.velocity = Vector2D:new(1.75, self.velocity.y)
    end

    if love.keyboard.isDown("up") and self.isTouchingGround then
        self.velocity.y = -6
    end

    if love.keyboard.isDown("space") then
        if self.canShoot == true then
            for i = 1, 3 do
                local newBullet = Bullet:new(self.position+Vector2D:new(10*self.directionX, -2), self.directionX)
                self.world:addEntity(newBullet)
            end
            self.shootWait = 1
            self.canShoot = false
        end
    else
        if self.shootWait < 0 then
            self.canShoot = true
        end
    end

    self:animation()

end

return Player