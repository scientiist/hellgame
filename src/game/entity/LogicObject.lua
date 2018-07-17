--| imports
    local Vector2D  = require("src.datatypes.Vector2D")
    local Rect      = require("src.datatypes.Rect")
    local Math      = require("src.utils.Math")
    local Entity    = require("src.game.entity.Entity")
--|

local LogicObject = Entity:subclass("LogicObject")


function LogicObject:init()
    self.super:init()
end

function LogicObject:render()
    
end

return LogicObject

