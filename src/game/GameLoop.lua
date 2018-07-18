--| imports
	local GameWorld  = require("src.game.GameWorld")
	local Entity     = require("src.game.entity.Entity")
	local Player     = require("src.game.entity.Player")
	local Vector2D   = require("src.datatypes.Vector2D")
	local TestEntity = require("src.game.entity.TestEntity")
	local Math       = require("src.utils.Math")
--|

local GameLoop = {}

local settings = {
    resolution = {x = 296, y = 224},
    upscale    = 4,
}

local testRoom = GameWorld:new()
local loadThread
love.graphics.setDefaultFilter("nearest", "nearest")
local fonts = {
	pixelade = love.graphics.newFont("assets/pixelade.ttf", 12),
	pressStart = love.graphics.newFont("assets/PrStart.ttf", 12),
	vga = love.graphics.newFont("assets/vgaFont.ttf", 16),
	default = love.graphics.newFont(12)
}

local inWorld = false
local inc = 0


function GameLoop:initialize()
	
    love.window.setMode(settings.resolution.x*settings.upscale, settings.resolution.y*settings.upscale, {
		resizable = false,
		fullscreen = false,
	})
	love.graphics.setBackgroundColor(0, 0, 0)
end

function GameLoop:tick()

end

function GameLoop:step(delta)
	if inWorld == false then
		inc = inc + 1/200

		if love.keyboard.isDown("space") then
			inWorld = true
			loadThread = testRoom:loadMap("test3")
		end
	else
		if testRoom.mapLoaded == true then
			testRoom:update(delta)
		else
			love.timer.sleep(1/10)
			coroutine.resume(loadThread)
		end
	end

	


end

function GameLoop:render()
	
	love.graphics.push()
	love.graphics.scale(settings.upscale, settings.upscale)

	if inWorld == false then
		love.graphics.setColor(1, 0.4, 0.5)
		love.graphics.setFont(fonts.vga)
		love.graphics.printf("Mister Shotgun", 0, 32, settings.resolution.x, "center")
		love.graphics.setColor(0.7, 0.7, 0.7)
		love.graphics.setFont(fonts.pixelade)
		love.graphics.printf("A computer game by Josh O'Leary.", 0, 48, settings.resolution.x, "center")

		love.graphics.printf("Arrow keys to move and jump.", 0, 128, settings.resolution.x, "center")
		love.graphics.printf("Spacebar to shoot.", 0, 140, settings.resolution.x, "center")


		local col = math.abs(math.sin(inc * 4 * math.pi))
		love.graphics.setColor(col, col, col)
		love.graphics.printf("Press space to start...", 0, 200, settings.resolution.x, "center")

		love.graphics.setFont(fonts.default)
		love.graphics.setColor(1, 1, 1)
	else
		----------------------------------
		if testRoom.mapLoaded then
			testRoom:render()
		else
			
			love.graphics.printf(testRoom.loadingStatus, 0, testRoom.cameraSize.y/2, testRoom.cameraSize.x, "center")
		end

	end
	----------------------------------
    love.graphics.pop()
end

return GameLoop