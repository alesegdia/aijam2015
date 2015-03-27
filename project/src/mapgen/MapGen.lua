

--
-- 0 -> free
-- 1 -> wall
-- 2 -> inside room
-- 3 -> door
--

local makeRoom1 = require "rooms.Room1"
local makeRoom2 = require "rooms.Room2"
local makeRoom3 = require "rooms.Room3"

local MapGen = {

	buildEmptyMap = function(width, height)
		local map = {}
		for i = 1,width do
			map[i] = {}
			for j = 1,height do
				map[i][j] = 0
			end
		end
		return map
	end,

	generate = function(self, width, height)

		local map = self.buildEmptyMap(width, height)
		local currentPos = { x = height/2, y = width/2 }

		love.math.setRandomSeed(0xFACEFEED)
		local rollDice = function()
			return love.math.random(0,5)
		end

		local cave = function(x,y)
			currentPos.x = math.floor(currentPos.x + x)
			currentPos.y = math.floor(currentPos.y + y)
			if currentPos.x >= width or currentPos.x < 1 then
				currentPos.x = math.floor(width/2)
			end
			if currentPos.y >= height or currentPos.y < 1 then
				currentPos.y = math.floor(height/2)
			end
			map[currentPos.x][currentPos.y] = 1
		end

		for i = 1,500 do
			local action = rollDice()
			if action == 0 then
				cave(1,0)
			elseif action == 1 then
				cave(-1,0)
			elseif action == 2 then
				cave(0,-1)
			elseif action == 3 then
				cave(0,1)
			elseif action == 4 then
				currentPos.x = currentPos.x + love.math.random(10) - 5
				currentPos.y = currentPos.y + love.math.random(10) - 5
			end
		end

		local themap = {
			data = map,
			size = { w = width, h = height }
		}

		return themap
	end
}

return MapGen
