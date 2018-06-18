local Rectangle = {}

setmetatable(Rectangle,{
    __index = Rectangle,
    __tostring = function(a) return "("..a.x1..','..a.y1..","..a.x2..","..a.y2..")" end
})

function Rectangle.overlaps(rect1, rect2)
    function CheckCollision(x1,y1,w1,h1, x2,y2,w2,h2)
        return x1 < w2 and
               x2 < w1 and
               y1 < h2 and
               y2 < h1
    end

    return CheckCollision(
        rect1.x1, rect1.y1, rect1.x2, rect1.y2,
        rect2.x1, rect2.y1, rect2.x2, rect2.y2
    )

end

function Rectangle:new(x, y, w, h)

    local newB = {
        x1 = x,
        y1 = y,
        x2 = w,
        y2 = h
    }

    return setmetatable(newB, getmetatable(self))
end

function Rectangle:fromRadius(r)
    return Rectangle:new(-r, -r, r, r)
end

function Rectangle:out()
    return self.x1, self.y1, self.x2, self.y2
end

return Rectangle