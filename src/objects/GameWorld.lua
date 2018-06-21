local newclass = require("src.objects.Yaci")

local Point = require("src.datatypes.Point")
local Rectangle = require("src.datatypes.Rectangle")

local GameWorld = newclass("GameWorld")

function GameWorld:init()
	self.name = "GameWorld"
    self.tilemap = {}
    self.entities = {}
	self.cameraPosition = Point:new(0, 0)
	self.cameraSize = Point:new(256, 224)
	self.font = love.graphics.newFont(12)
	self.tileSize = 8

end

function GameWorld:populateTilemap()
	for y = 1, 42 do
		self.tilemap[y] = {}
		for x = 1, 200 do
			self.tilemap[y][x] = 0
		end
	end
end

function GameWorld:setTile(x, y, tile)
	self.tilemap[y][x] = tile
end

function GameWorld:addEntity(entity)
    table.insert(self.entities, entity)
end

function GameWorld:getExtents()

	return Rectangle:new(
		self.cameraPosition.x, self.cameraPosition.y,
		self.cameraPosition.x+self.cameraSize.x, self.cameraPosition.y+self.cameraSize.y
	)
end

function GameWorld:isEntityVisible(entity)
	local viewWindow = self:getExtents()

	return viewWindow:overlaps(entity:getExtents())
end


function GameWorld:render()

	local fps = "fps: ".. love.timer.getFPS()
	local luamem = "\nluamem: "..math.floor(collectgarbage('count')).."kB"
	local entities = "\nentities: "..#self.entities
	local camPos = "\ncamera: "..self.cameraPosition.x..", "..self.cameraPosition.y

	local debugInfo = fps..luamem..entities..camPos

	-- debug information
	love.graphics.push()
	love.graphics.scale(0.25, 0.25)
	love.graphics.setFont(self.font)
	love.graphics.setColor(1,1,1)
	love.graphics.print(debugInfo, 2, 2)
	love.graphics.pop()
	
	-- ok start the real rendering
    love.graphics.push()
	love.graphics.translate(self.cameraPosition.x, self.cameraPosition.y)
	
	for yIndex, xTable in pairs(self.tilemap) do
		for xIndex, tile in pairs(xTable) do
			if tile == 1 then
				love.graphics.setColor(0.2, 1, 0.2)
				love.graphics.rectangle("fill", (xIndex-1)*self.tileSize, (yIndex-1)*self.tileSize, self.tileSize, self.tileSize)
			end
		end
	end

    -- check if entity is within bounds to be rendered
    for idx, entity in pairs(self.entities) do
		if self:isEntityVisible(entity) then
			entity:render()
		end
    end
    
    love.graphics.pop()
end

function GameWorld:update(delta)
    for idx, entity in pairs(self.entities) do

        -- remove entities marked for destruction
        if entity.markedForRemoval then
            self.entities[idx] = nil
            return
        end

		-- if entities should be destroyed offscreen
		-- check for them and do so here
		if entity.destroyWhenOffScreen then
			if not self:isEntityVisible(entity) then
				entity:destroy()
				return
			end
		end

		-- lastly, let's update the entities on screen
		if (entity.pauseWhenOffScreen == false) or self:isEntityVisible(entity) then
			entity:update(delta)
		end 

    end
end


return GameWorld