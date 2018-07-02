local Entity = require("src.game.entity.Entity")


local LivingEntity = Entity:subclass("LivingEntity")
    LivingEntity.maxhealth = 20

function LivingEntity:init()
    self.super:init()
    
    self.health = 20
end

return LivingEntity