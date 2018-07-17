--| imports
local Vector2D  = require("src.datatypes.Vector2D")
local Rect      = require("src.datatypes.Rect")
local Math      = require("src.utils.Math")
local LogicObject    = require("src.game.entity.LogicObject")
--|

local ANDGate = LogicObject:subclass("ANDGate")


function ANDGate:init()
    self.super:init()
end

function ANDGate:update()

end

function ANDGate:render()

end

return ANDGate

