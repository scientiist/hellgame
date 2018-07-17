local Rect = {}

setmetatable(Rect,{
	__index = Rect,
	__tostring = function(a) return "Rect" end
})

function Rect.overlaps(rect1, rect2)

	function testCollision(a, b)
		-- distance between rects
		local distanceX, distanceY = a.x - b.x, a.y - b.y

		local aDistX = math.abs(distanceX)
		local aDistY = math.abs(distanceY)

		local sumWidth = a.halfWidth + b.halfWidth
		local sumHeight = a.halfHeight + b.halfHeight

		if aDistX >= sumWidth or aDistY >= sumHeight then
			-- no intersection
			return false
		end

		local sx, sy = sumWidth - aDistX, sumHeight - aDistY

		if sx < sy then
			if sx > 0 then sy = 0 end
		else
			if sy > 0 then sx = 0 end
		end

		if distanceX < 0 then sx = -sx end
		if distanceY < 0 then sy = -sy end
		return sx, sy
	end

	return testCollision(rect1, rect2)

end



function Rect.addVec(rect1, vec)
	if tostring(vec) == "Vector2D" then
		return Rect:new(
			rect1.x+vec.x,
			rect1.y+vec.y,
			rect1.halfWidth,
			rect1.halfHeight
		)
	end
end

function Rect:new(x, y, halfWidth, halfHeight)

	local new = {
		x = x,
		y = y,
		halfWidth = halfWidth,
		halfHeight = halfHeight
	}

	return setmetatable(new, getmetatable(self))
end

function Rect:fromPoints(Vec1, Vec2)
	
end

function Rect:out()
	return self.x, self.y, self.halfWidth, self.halfHeight
end

return Rect