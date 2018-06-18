--[[
	the main file LOVE requires to start up the game
]]

local GameLoop = require("src.game.GameLoop")


function love.load()	
	GameLoop:initialize()
end

local updateTrack = 0
local tick = 0

function love.update(delta)
	updateTrack = updateTrack + delta
	tick = tick + delta

	if not (updateTrack > (1/60)) then return end
	updateTrack = 0

	GameLoop:step()

	if tick > (1/20) then
		tick = 0
		GameLoop:tick()
	end

end

function love.draw()
	GameLoop:render()
end