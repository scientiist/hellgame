--| imports
	local Yaci      = require("src.libs.Yaci")
	local Vector2D  = require("src.datatypes.Vector2D")
	local Rect      = require("src.datatypes.Rect")
	local LoveImage = require("src.datatypes.LoveImage")
	local Math      = require("src.utils.Math")
	local TileLayer = require("src.game.TileLayer")
--|

local GameWorld = Yaci:newclass("GameWorld")

local EntityLoaderList = {
	["PlayerSpawn"] = require("src.game.entity.Player"),
	["ANDGate"] = require("src.game.entity.ANDGate"),
}

function GameWorld:init()
	self.name = "GameWorld"
	self.tilesets = {}
	self.tiles = {}
    self.layers = {}
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

function GameWorld:loadStatus(string)
	self.loadingStatus = string
	coroutine.yield()
end

function GameWorld:loadMap(mapName)
	local co = coroutine.create(function()
		self:loadStatus("Getting mapdata file...")
		local mapData = require("assets/levels/"..mapName)

		self.width = mapData["width"]
		self.height = mapData["height"]

		self:loadStatus("Loading tiles...")
		for index, tileset in pairs(mapData["tilesets"]) do

			if tileset["name"] ~= "entitypreviews" then
				self:loadStatus("Loading tileset " .. tileset["name"] .. "...")
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
		end


		self:loadStatus("Loading layers...")
		for index, layer in pairs(mapData["layers"]) do
			if layer["type"] == "tilelayer" then

				self:loadStatus("Loading tilelayer ".. layer["name"])

				local newLayer = TileLayer:new(layer, self)
				table.insert(self.layers, newLayer)
				
			end
			if layer["type"] == "objectgroup" and layer["name"] == "Entities" then
				print("gank2")
				self:loadStatus("Loading objects...")
				for index, entity in pairs(layer["objects"]) do
					print(entity)
					local type = entity["type"]
					print("AAAAAAAAAAAAAAAAa")
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
		
		self.mapLoaded = true
		self:loadStatus("Done!")
	end)

	return co
end

function GameWorld:setCameraFocus(entity)
	self.cameraFocus = entity
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

function GameWorld:getLayer(name)
	for index, layer in pairs(self.layers) do
		if layer.name == name then return layer end
	end
end

function GameWorld:getLayerByZ(zIndex)
	for index, layer in pairs(self.layers) do
		if layer.renderOrder == zIndex then return layer end
	end
end

function GameWorld:getLayers()
	return self.layers
end

function GameWorld:render()

	-- ok start the real rendering
	love.graphics.push()
	love.graphics.translate(-self.cameraPosition.x, -self.cameraPosition.y)
	
	for i = -5, 0 do
		local l = self:getLayerByZ(i)
		if l then l:render() end
	end

	-- render entities at index 0
	for idx, entity in pairs(self.entities) do
		if self:isEntityVisible(entity) then
			entity:render()
		end
	end

	for i = 1, 5 do
		local l = self:getLayerByZ(i)
		if l then l:render() end
	end
    
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

function GameWorld:solveCollision(entity, normal, separation, tile)
	if entity.destroyOnTileCollide == true then
		entity.markedForRemoval = true
		entity:destroy()
	else
		entity.nextPosition = entity.nextPosition + separation
	end
	entity:collisionTileCallback(tile, normal.x, normal.y)
	if normal.y == -1 then
		if entity.hasMass == true then
			applyGravity = false
			entity.velocity.y = 0
			entity.isTouchingGround = true
		end
	end
	if normal.y == 1 then
		if entity.hasMass then
			entity.velocity.y = -(entity.velocity.y*0.3)
		end
	end
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

		for _, layer in pairs(self:getLayers()) do
			if layer:isSolid() then
				local collision = layer:entityCollisionCheck(entity)
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

		-- if entities should be destroyed offscreen
		-- check for them and do so here
		if entity.destroyWhenOffScreen then
			if not self:isEntityVisible(entity) then
				entity:destroy()
				entity.markedForRemoval = true
			end
		end

		-- remove entities marked for destruction
        if entity.markedForRemoval then
            self.entities[idx] = nil
        end
    end
end

return GameWorld