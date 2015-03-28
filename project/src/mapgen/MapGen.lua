

--
-- 0 -> free
-- 1 -> wall
-- 2 -> inside room
-- 3 -> door
--

local Vector        = require (LIBRARYPATH.."hump.vector"	)
local makeRoom1 = require "rooms.Room1"
local makeRoom2 = require "rooms.Room2"
local makeRoom3 = require "rooms.Room3"

local MapGen = {

	getDoors = function(self, map)
		return self:getTilesOfKind(map, 3)
	end,

	getUsed = function(self, map)
		return self:getTilesOfKind(map, 2)
	end,

	getTilesOfKind = function(self, map, kind)
		local doors  = {}
		for i=1,#map do
			local row = map[i]
			for j=1,#row do
				if row[j] == kind then
					table.insert(doors, { x=i, y=j })
				end
			end
		end
		return doors
	end,

	dumpMap = function(self, src, target, where)
		local obj = { should_break_loop = false }
		local data = self.applyMap(src, target, where, obj, function(dx1, dy1, dx2, dy2, obj)
			if src[dx1][dy1] ~= 0 then
				target[dx2][dy2] = src[dx1][dy1]
			end
		end)
	end,

	doesCollide = function(self, src, target, where)
		local objj = { ret = false, should_break_loop = false }
		local data = self.applyMap(src, target, where, objj, function(dx1, dy1, dx2, dy2, obj)
			obj.ret = (target[dx2][dy2] ~= 0 and src[dx1][dy1] ~= 0)
			if obj.ret then
				obj.should_break_loop = true
			end
		end)
		return objj.ret
	end,

	-- obj = { should_break_loop = false }
	applyMap = function(src, target, where, obj, func)
		for i1=1,#src do
			local row = src[i1]
			for j1=1,#row do
				func(i1, j1, i1 + where.x, j1 + where.y, obj)
				if obj.should_break_loop then break end
			end
			if obj.should_break_loop then break end
		end
		return obj
	end,

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

		return map
	end,

	tryWeldRoomInMap = function(self, room, map)
		local roomDoors = self:getDoors(room)
		local mapDoors = self:getDoors(map)
		local selected_door = nil
		local selected_pos = nil
		for _,roomDoor in pairs(roomDoors) do
			if selected_door ~= nil then break end
			for _,mapDoor in pairs(mapDoors) do
				if selected_door ~= nil then break end
				local deltas = { {1,0}, {0,1}, {-1,0}, {0,-1} }
				while #deltas > 0 do
					local rand = love.math.random(#deltas)
					local obj = deltas[rand]
					table.remove(deltas, rand)
					local pos = { x = mapDoor.x - roomDoor.x + obj[1], y = mapDoor.y - roomDoor.y + obj[2] }
					if not self:doesCollide(room, map, pos) then
						self:dumpMap(room, map, pos)
						selected_door = { mapDoor, roomDoor }
						selected_pos = pos
					end
				end
			end
		end
		map[selected_door[1].x][selected_door[1].y] = 2
		map[selected_pos.x + selected_door[2].x][selected_pos.y + selected_door[2].y] = 2
	end,

	closeDoors = function(self, map)
		local doors = self:getDoors(map)
		for k,v in pairs(doors) do
			map[v.x][v.y] = 1
		end
	end,

	generate2 = function(self, width, height, numRooms)
		local bigmap = self.buildEmptyMap(128, 128)
		local rm1 = makeRoom1()
		local rm2 = makeRoom2()
		self:dumpMap(rm1, bigmap, {x=20, y=20} )
		self:tryWeldRoomInMap(rm2, bigmap)
		for i=1,numRooms do
			local rand = love.math.random()
			local room = nil
			if rand < 0.3333 then
				room = makeRoom1()
			elseif rand < 0.6666 then
				room = makeRoom2()
			else
				room = makeRoom3()
			end
			self:tryWeldRoomInMap(room, bigmap)
		end
		self:closeDoors(bigmap)
		return bigmap
	end,

	getRandomValidTile = function(self, map)
		local tiles = self:getTilesOfKind(map, 2)
		return tiles[love.math.random(#tiles)]
	end,

	getRandomNearbyValidTile = function(self, map, pos, min, max)
		min = min or 700
		max = max or 1000
		local poss = pos
		local teret = self:getRandomValidTileWithCondition(map, function(tile)
			local dist = (Vector(tile.x * 128, tile.y * 128) - poss):len()
			local ret = dist > min and dist < max
			return ret
		end)
		return teret
	end,

	getRandomValidTileWithCondition = function(self, map, predicate)
		local tiles = self:getTilesOfKind(map, 2)
		local deftiles = {}
		for k, v in pairs(tiles) do
			if predicate(v) then
				table.insert(deftiles, v)
			end
		end
		local rand = love.math.random(#deftiles)
		local ret = deftiles[rand]
		return deftiles[rand]
	end
}

return MapGen
