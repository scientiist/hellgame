local GameWorld = require("src.objects.GameWorld")
local Entity = require("src.objects.entity.Entity")
local Player = require("src.objects.entity.Player")

local GameLoop = {}

local settings = {
    resolution = {x = 296, y = 224},
    upscale    = 4,
}

local testRoom = GameWorld:new()
testRoom:populateTilemap()
for i = 1, 100 do
	testRoom:setTile(i, 16, 1)
end
testRoom:setTile(2, 15, 1)
testRoom:setTile(2, 14, 1)

local player = Player:new()

testRoom:addEntity(player)

function GameLoop:initialize()
	
    love.window.setMode(settings.resolution.x*settings.upscale, settings.resolution.y*settings.upscale, {
		resizable = false,
		fullscreen = false,
	})
	love.graphics.setBackgroundColor(0.2, 0.15, 0.15)
end

function GameLoop:tick()

end

function GameLoop:step(delta)
	testRoom:update(delta)
end

function GameLoop:render()
	love.graphics.push()
	love.graphics.scale(settings.upscale, settings.upscale)
	----------------------------------

	testRoom:render()

	----------------------------------
    love.graphics.pop()
end

return GameLoop