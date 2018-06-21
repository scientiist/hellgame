local Entity = require("src.objects.entity.Entity")


local LivingEntity = Entity:subclass("LivingEntity")

function LivingEntity:init()
    self.super:init()

    self.health = 10
    self.maxHealth = 10
    
end

return LivingEntity