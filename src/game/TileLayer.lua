--| imports
    local Yaci      = require("src.libs.Yaci")
	local Vector2D  = require("src.datatypes.Vector2D")
	local Rect  = require("src.datatypes.Rect")
    local Math      = require("src.utils.Math")
--|

local TileLayer = Yaci:newclass("TileLayer")

function TileLayer:init(layerdata, world)
	self.data = layerdata["data"]
	self.name = layerdata["name"]

	self.width = layerdata["width"]
	self.height = layerdata["height"]
	self.renderOrder = layerdata["properties"]["index"]
	self.world = world
    self.solid = layerdata["properties"]["solid"]
    self.canvas = love.graphics.newCanvas(self.width*8, self.height*8)


    love.graphics.setCanvas(self.canvas)
        --love.graphics.clear()
        love.graphics.setBlendMode("alpha")
        love.graphics.setColor(1, 1, 1)
        for tileID, x, y in self:iterate() do
            if tileID > 0 then
                local tile = self.world.tiles[tileID]
                love.graphics.draw(tile.image, tile.quad, (x-1)*self.world.tileSize, (y-1)*self.world.tileSize)
            end
        end
    love.graphics.setCanvas()
end

function TileLayer:iterate()
	local index = 0
	return function()
		index = index+1
	
		local width = self.width
		local height = self.height
	
		if index > (width*height) then return end
		local tileID = self.data[index]
	
		local i = index - 1
		local x = i%width
		local y = (i - x)/width
		x, y = x + 1, y + 1
	
		return tileID, x, y
	end
end

function TileLayer:isSolid()
	return self.solid
end

function TileLayer:getZ()
	return self.renderOrder
end

function TileLayer:iterateActiveArea()
	local world = self.world

	local width, height = self.width, self.height

	local camPosX, camPosY = world.cameraPosition.x, world.cameraPosition.y
	local camSizeX, camSizeY = world.cameraSize.x, world.cameraSize.y
	
	local gridPosX, gridPosY = math.floor(camPosX/world.tileSize), math.floor(camPosY/world.tileSize)
	
	local gridSizeX, gridSizeY = math.floor(camSizeX/world.tileSize), math.floor(camSizeY/world.tileSize)
	
	local minX, minY = gridPosX-1, gridPosY-1
	local maxX, maxY = (gridPosX+gridSizeX)+1, (gridPosY+gridSizeY)+1

	minX, minY, maxX, maxY = math.max(minX, 1), math.max(minY, 0), math.min(maxX, width), math.min(maxY, height)
	
	local minIndex = minX + minY*width
	local maxIndex = maxX + maxY*width
	
	local idx = minIndex-1
	
	return function()
		idx = idx + 1
		if idx > maxIndex then return end
	
			
	
		local tileID = self.data[idx]
		local i = idx - 1
		local x = i%width
		local y = (i - x)/width
		x, y = x + 1, y + 1
		return tileID, x, y
	end
end

function TileLayer:entityCollisionCheck(entity)

	for tileID, xIndex, yIndex in self:iterateActiveArea() do
		if tileID > 0 then

		--	local curExtents = entity:getExtents()
		--	local nextExtents = entity:getNextFrameExtents()
				local extents = entity:getNextFrameExtents()


				local x = (xIndex-1)*self.world.tileSize
				local y = (yIndex-1)*self.world.tileSize
				local half = self.world.tileSize/2
			
				local tileBounds = Rect:new(x+half, y+half, half, half)
				local sx, sy = extents:overlaps(tileBounds)
				if sx and sy then
					
					-- find collision normal
					local d = math.sqrt(sx*sx + sy*sy)
					local nx, ny = sx/d, sy/d

					--print(nx, ny)
					-- relative velocity
					local vx, vy = entity.velocity.x, entity.velocity.y

					-- penetration speed
					local ps = vx*nx + vy*ny

					if ps <= 0 then
						self.world:solveCollision(entity, Vector2D:new(nx, ny), Vector2D:new(sx, sy), tileID)
					end
				end
		end
	end
end

function TileLayer:render()
	love.graphics.draw(self.canvas, 0, 0)
end

return TileLayer