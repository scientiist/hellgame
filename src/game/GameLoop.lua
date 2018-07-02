--| imports
	local GameWorld  = require("src.game.GameWorld")
	local Entity     = require("src.game.entity.Entity")
	local Player     = require("src.game.entity.Player")
	local Vector2D   = require("src.datatypes.Vector2D")
	local TestEntity = require("src.game.entity.TestEntity")
--|

local GameLoop = {}

local settings = {
    resolution = {x = 296, y = 224},
    upscale    = 4,
}

local testRoom = GameWorld:new()
testRoom:loadMap("test2")


local player = Player:new()

print(player.hasMass)


testRoom:addEntity(player)

player.position = Vector2D:new(20*8, 27*8)
player.nextPosition = Vector2D:new(20*8, 27*8)

--testRoom:addEntity(testentity)

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

	love.graphics.setColor(0.6, 0.6, 0.6, 0.6)
	love.graphics.rectangle("fill", testRoom.cameraPosition.x+(math.floor(love.mouse.getX()/8)*8), testRoom.cameraPosition.y+(math.floor(love.mouse.getY()/8)*8), 8, 8)
	love.graphics.setColor(1, 1, 1)

	----------------------------------
    love.graphics.pop()
end

return GameLoop