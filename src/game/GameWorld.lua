--| imports
	local Yaci      = require("src.libs.Yaci")
	local Vector2D  = require("src.datatypes.Vector2D")
	local Rect      = require("src.datatypes.Rect")
	local LoveImage = require("src.datatypes.LoveImage")
	local Math      = require("src.utils.Math")
	local Player    = require("src.game.entity.Player")
--|

local TileLayer = Yaci:newclass("TileLayer")

local GameWorld = Yaci:newclass("GameWorld")

local EntityLoaderList = {
	["Player"] = Player
}

function GameWorld:init()
	self.name = "GameWorld"
	self.tilesets = {}
	self.tiles = {}
    self.tilemap = {}
    self.entities = {}
	self.cameraPosition = Vector2D:new(0, 0)
	self.cameraSize = Vector2D:new(296, 224)
	self.font = love.graphics.newFont(12)
	self.tileSize = 8
	self.staticCamera = false
	self.cameraFocus = nil
	self.debug = false
	self.mapLoaded = false
	self.loadingStatus = "Loading..."

	self.width = 0
	self.height = 0
end

function GameWorld:loadMap(mapName)
	local co = coroutine.create(function()
		self.loadingStatus = "Getting mapdata file..."
		local mapData = require("assets/levels/"..mapName)

		self.width = mapData["width"]
		self.height = mapData["height"]

		self.loadingStatus = "Loading tiles..."
		coroutine.yield()
		for index, tileset in pairs(mapData["tilesets"]) do
			self.loadingStatus = "Loading tileset " .. tileset["name"] .. "..."
			coroutine.yield()
			local newTileset = {}

			local image = LoveImage:new("assets/tilesets/"..tileset["name"]..".png")

			local imageHeight = tileset["imageheight"]
			local imageWidth = tileset["imagewidth"]


			newTileset.image = image
			self.tilesets[tileset["name"]] = newTileset

			local i = 0
			for y = 1, imageHeight/self.tileSize do
				for x = 1, imageWidth/self.tileSize do
					
					self.tiles[i+tileset["firstgid"]] = {
						image = self.tilesets[tileset["name"]].image,
						quad = love.graphics.newQuad((x-1)*self.tileSize, (y-1)*self.tileSize, self.tileSize, self.tileSize, image:getDimensions())
					}
					i = i + 1
				end
			end
		end


		self.loadingStatus = "Loading layers..."
		coroutine.yield()
		for index, layer in pairs(mapData["layers"]) do
			if layer["type"] == "tilelayer" then

				local newLayer = {}

				self.loadingStatus = "Loading tilelayer ".. layer["name"]
				coroutine.yield()

				newLayer["data"] = layer["data"]
				newLayer["width"] = layer["width"]
				newLayer["height"] = layer["height"]

				self.tilemap[layer["name"]] = newLayer
			end

			if layer["type"] == "objectgroup" and layer["name"] == "Entities" then
				self.loadingStatus = "Loading objects..."
				coroutine.yield()
				for index, entity in pairs(layer["objects"]) do
					local type = entity["type"]
					local entityClass = EntityLoaderList[type]
					if entityClass then
						local instance = entityClass:new()

						instance:setPosition(Vector2D:new(entity["x"], entity["y"]))
						self:addEntity(instance)

						if entity["properties"]["takeCameraFocus"] == true then
							self:setCameraFocus(instance)
						end
					end
				end
			end
		end
		self.loadingStatus = "Done!"
		self.mapLoaded = true
		coroutine.yield()
	end)

	return co
end

function GameWorld:setCameraFocus(entity)
	self.cameraFocus = entity
end

function GameWorld:getTile(layer, x, y, tile)


	--self.tilemap[layer]["data"][tilePos] = tile
end

function GameWorld:getTileImage(id)

end

function GameWorld:addEntity(entity)
	table.insert(self.entities, entity)
	entity.world = self
end

function GameWorld:isEntityVisible(entity)
	local epos = entity.position
	local cpos = self.cameraPosition
	return ((epos.x+entity.body.halfWidth) > cpos.x 
	and (epos.x-entity.body.halfWidth) < cpos.x+self.cameraSize.x 
	and (epos.y+entity.body.halfHeight) > cpos.y 
	and (epos.y-entity.body.halfHeight) < cpos.y+self.cameraSize.y)
end

function GameWorld:iterateLayer(layer)

	local index = 0
	return function()
		index = index+1

		local width = layer["width"]
		local height = layer["height"]

		if index > (width*height)  then return end
		local tileID = layer["data"][index]

		local i = index - 1
		local x = i%width
		local y = (i - x)/width
		x, y = x + 1, y + 1

		return tileID, x, y
	end
end

function GameWorld:visibleLayerIterate(layer)

	local camPosX, camPosY = self.cameraPosition.x, self.cameraPosition.y
	local camSizeX, camSizeY = self.cameraSize.x, self.cameraSize.y

	local gridPosX, gridPosY = math.floor(camPosX/self.tileSize), math.floor(camPosY/self.tileSize)

	local gridSizeX, gridSizeY = math.floor(camSizeX/self.tileSize), math.floor(camSizeY/self.tileSize)

	local topLeftX, topLeftY = gridPosX-1, gridPosY-1
	local bottomLeftX, bottomLeftY = (gridPosX+gridSizeX)+1, (gridPosY+gridSizeY)+1
	
	local minX, minY = topLeftX, topLeftY
	local maxX, maxY = bottomLeftX, bottomLeftY

	minX = (minX > 0) and minX or 1
	minY = (minY > 0) and minY or 0


	local width = layer["width"]
	local height = layer["height"]

	maxX = (maxX <= width) and maxX or width
	maxY = (maxY <= height) and maxY or height

	local minIndex = minX + minY*width
	local maxIndex = maxX + maxY*width



	local idx = minIndex-1

	return function()
		idx = idx + 1
		if idx > maxIndex then return end

		

		local tileID = layer["data"][idx]
		local i = idx - 1
		local x = i%width
		local y = (i - x)/width
		x, y = x + 1, y + 1
		return tileID, x, y
	end

end

function GameWorld:renderLayer(layer)
	love.graphics.setColor(1, 1, 1)



	for tileID, x, y in self:visibleLayerIterate(layer) do
		

		if tileID > 0 then
			local tile = self.tiles[tileID]
			love.graphics.draw(tile.image, tile.quad, (x-1)*self.tileSize, (y-1)*self.tileSize)
		end
	end


end

function GameWorld:render()

	-- ok start the real rendering
	love.graphics.push()
	love.graphics.translate(-self.cameraPosition.x, -self.cameraPosition.y)
	
	self:renderLayer(self.tilemap["Background"])


	self:renderLayer(self.tilemap["Collide"])
	
	for idx, entity in pairs(self.entities) do
		if self:isEntityVisible(entity) then
			entity:render()
		end
	end
	

	self:renderLayer(self.tilemap["Foreground"])
    
	love.graphics.pop()
	
	
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
end

function GameWorld:update(delta)

	if self.cameraFocus then
		local entity = self.cameraFocus
		local camX = Math:clamp(entity.position.x-entity.body.halfWidth - (self.cameraSize.x/2), 1, (self.width*self.tileSize) -(self.cameraSize.x))
		local camY = Math:clamp(entity.position.y-entity.body.halfHeight - (self.cameraSize.y/2), 1, (self.height*self.tileSize) -(self.cameraSize.y))

		self.cameraPosition = Vector2D:new(camX, camY)
	end

    for idx, entity in pairs(self.entities) do


		entity.isTouchingGround = false

		
		local applyGravity = true

		--for tileID, xIndex, yIndex in self:iterateLayer(self.tilemap["Collide"]) do
		for tileID, xIndex, yIndex in self:visibleLayerIterate(self.tilemap["Collide"]) do
			if tileID > 0 then 
				local extents = entity:getNextFrameExtents()

				local x = (xIndex-1)*self.tileSize
				local y = (yIndex-1)*self.tileSize
				local half = self.tileSize/2
					
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
						if entity.destroyOnTileCollide == true then
							entity.markedForRemoval = true
							entity:destroy()
						else
							entity.nextPosition = entity.nextPosition + Vector2D:new(sx, sy)
						end
						entity:collisionTileCallback(tile, nx, ny)
						if ny == -1 then
							if entity.hasMass == true then
								applyGravity = false
								entity.velocity.y = 0
								entity.isTouchingGround = true
							end
						end
						if ny == 1 then
							if entity.hasMass then
								entity.velocity.y = -(entity.velocity.y*0.3)
							end
						end
					end
				end
			end
		end


		if applyGravity == true and entity.hasMass == true then
			entity.velocity.y = entity.velocity.y + 0.5
			if entity.velocity.y > 5 then entity.velocity.y = 5 end
		end

		-- lastly, let's update the entities on screen
		if (entity.pauseWhenOffScreen == false) or self:isEntityVisible(entity) then
			entity:update(delta)
		end

		-- remove entities marked for destruction
        if entity.markedForRemoval then
            self.entities[idx] = nil
            --return
        end

		-- if entities should be destroyed offscreen
		-- check for them and do so here
		if entity.destroyWhenOffScreen then
			if not self:isEntityVisible(entity) then
				entity:destroy()
				entity.markedForRemoval = true
				--return
			end
		end

    end
end


return GameWorld