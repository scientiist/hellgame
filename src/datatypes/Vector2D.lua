local Vector2D = {}

setmetatable(Vector2D,{
    __index = Vector2D,
    __add = function(a, b) return Vector2D:new(a.x + b.x, a.y + b.y) end,
    __mul = function(a, b) return Vector2D:new(a.x * b.x, a.y * b.y) end,
    __tostring = function(a) return "("..a.x..','..a.y..")" end
})

function Vector2D:new(x, y)
    local newP = {
        x = x,
        y = y
    }

    return setmetatable(newP, getmetatable(self))
end

function Vector2D:out()
    return self.x, self.y
end

return Vector2D