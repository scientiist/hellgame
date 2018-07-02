--| imports
	local Yaci     = require("src.libs.Yaci")
	local Vector2D = require("src.datatypes.Vector2D")
	local Rect     = require("src.datatypes.Rect")
	local LoveImage = require("src.datatypes.LoveImage")
--|

local GameWorld = Yaci:newclass("GameWorld")

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
end

function GameWorld:loadMap(mapName)
	local mapData = require("assets/levels/"..mapName)

	for index, tileset in pairs(mapData["tilesets"]) do
		print("load tileset", tileset["name"])
		local newTileset = {}

		local image = LoveImage:new("assets/tilesets/"..tileset["name"]..".png")


		local imageHeight = tileset["imageheight"]
		local imageWidth = tileset["imagewidth"]



		self.tilesets[tileset["name"]] = newTileset

		local i = 0
		for y = 1, imageHeight/self.tileSize do
			for x = 1, imageWidth/self.tileSize do
				
				print("newtile", i+tileset["firstgid"])
				self.tiles[i+tileset["firstgid"]] = {
					image = image,
					quad = love.graphics.newQuad((x-1)*self.tileSize, (y-1)*self.tileSize, self.tileSize, self.tileSize, image:getDimensions())
				}
				i = i + 1
			end
		end
	end


	
	for index, layer in pairs(mapData["layers"]) do
		if layer["type"] == "tilelayer" then
			local newLayer = {}

			print("load tilelayer", layer["name"])

			newLayer["data"] = layer["data"]
			newLayer["width"] = layer["width"]
			newLayer["height"] = layer["height"]

			self.tilemap[layer["name"]] = newLayer
		end

		if layer["type"] == "objectgroup" and layer["name"] == "Entities" then

		end
	end
	
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

function GameWorld:renderLayer(layer)
	love.graphics.setColor(1, 1, 1)
	for tileID, x, y in self:iterateLayer(layer) do

			
		if not (tileID == 0) then
			
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

		entity.isTouchingGround = false

		
		local applyGravity = true

		for tileID, x, y in self:iterateLayer(self.tilemap["Collide"]) do
			if tileID > 0 then 
				
			end
		end

	--[[for yIndex, xTable in pairs(self.tilemap) do
			for xIndex, tile in pairs(xTable) do
				if tile == 1 then
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
							entity.nextPosition = entity.nextPosition + Vector2D:new(sx, sy)
							entity:collisionTileCallback(tile, nx, ny)
							if ny == -1 then
								if entity.hasMass then
									applyGravity = false
									entity.velocity.y = 0
									entity.isTouchingGround = true
								end
							end

							if ny == 1 then
								entity.velocity.y = -(entity.velocity.y*0.2)
							end
							
						end

					end
				end
			end
		end]]

		if applyGravity == true then
			--entity.velocity.y = entity.velocity.y + 0.5
			if entity.velocity.y > 4 then entity.velocity.y = 4 end
		end

		-- lastly, let's update the entities on screen
		if (entity.pauseWhenOffScreen == false) or self:isEntityVisible(entity) then
			entity:update(delta)
		end

    end
end


return GameWorld