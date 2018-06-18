local GameWorld = require("src.objects.GameWorld")
local Entity = require("src.objects.entity.Entity")

local GameLoop = {}

local settings = {
    resolution = {x = 256, y = 224},
    upscale    = 4,
}

local testRoom = GameWorld:new()

local testEntity = Entity:new()

testRoom:addEntity(testEntity)

function GameLoop:initialize()
	love.graphics.setDefaultFilter("nearest", "nearest")
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