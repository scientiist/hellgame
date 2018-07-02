local Entity = require("src.game.entity.Entity")

local TestEntity = Entity:subclass("TestEntity")

function TestEntity:init()
    self.super:init()

end


function TestEntity:render()
    self.super:render()
end

return TestEntity