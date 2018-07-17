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
local loadThread = testRoom:loadMap("test3")




function GameLoop:initialize()
	love.graphics.setDefaultFilter("nearest", "nearest")
    love.window.setMode(settings.resolution.x*settings.upscale, settings.resolution.y*settings.upscale, {
		resizable = false,
		fullscreen = false,
	})
	love.graphics.setBackgroundColor(0, 0, 0)
end

function GameLoop:tick()

end

function GameLoop:step(delta)
	if testRoom.mapLoaded == true then
		testRoom:update(delta)
	else
		love.timer.sleep(1/10)
		coroutine.resume(loadThread)
	end
	


end

function GameLoop:render()
	
	love.graphics.push()
	love.graphics.scale(settings.upscale, settings.upscale)
	----------------------------------
	if testRoom.mapLoaded then
		testRoom:render()
	else
		
		love.graphics.printf(testRoom.loadingStatus, 0, testRoom.cameraSize.y/2, testRoom.cameraSize.x, "center")
	end


	----------------------------------
    love.graphics.pop()
end

return GameLoop