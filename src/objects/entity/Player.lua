local LivingEntity = require("src.objects.entity.LivingEntity")
local Vector2D = require("src.datatypes.Vector2D")
local Point = require("src.datatypes.Point")
local Assets = require("src.game.Assets")
local Rectangle = require("src.datatypes.Rectangle")

local Player = LivingEntity:subclass("Player")


function Player:init()
    
    self.super:init()
    self.sprite = Assets.sprites["player"]
    self.isMoving = false
    self.deltaTracker = 0
    self.body = Rectangle:new(-6, -12, 6, 12)
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
end

function Player:update(delta)
    self.super:update(delta)
    self.deltaTracker = self.deltaTracker + delta
    self.isMoving = false

    if love.keyboard.isDown("left") then
        self.isMoving = true
        self.directionX = -1
        self.position = self.position + Point:new(-1.5, 0)
    end

    if love.keyboard.isDown("right") then
        self.isMoving = true
        self.directionX = 1
        self.position = self.position + Point:new(1.5, 0)
    end

    if love.keyboard.isDown("space") then

    end

    self:animation()

end

function Player:draw()
    self.super:draw()
end

return Player