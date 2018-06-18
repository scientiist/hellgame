local Point = {}

setmetatable(Point,{
    __index = Point,
    __add = function(a,b) return Point:new(a.x+b.x,a.y+b.y) end,
    __tostring = function(a) return "("..a.x..','..a.y..")" end
})

function Point:new(x, y)
    local newP = {
        x = x,
        y = y
    }

    return setmetatable(newP, getmetatable(self))
end

function Point:out()
    return self.x, self.y
end

return Point