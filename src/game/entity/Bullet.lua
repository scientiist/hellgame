local Entity = require("src.game.entity.Entity")

local Bullet = Entity:subclass("Bullet")

function Bullet:init(x, y, direction)
    self.super:init()
end

function Bullet:update(delta)
    self.super:update(delta)


end

function Bullet:render()
    
end

return Bullet