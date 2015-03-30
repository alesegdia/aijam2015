--
--  Game
--

local Gamestate     = require (LIBRARYPATH.."hump.gamestate")
local gui       = require( LIBRARYPATH.."Quickie"           )
local camera = require (LIBRARYPATH.."hump.camera")
timer = require (LIBRARYPATH.."hump.timer")
local Vector        = require (LIBRARYPATH.."hump.vector"	)
local tween         = timer.tween
local gui = require (LIBRARYPATH.."Quickie")

require "src.entities.Stage"
require "src.entities.GameEntity"
require "src.entities.PhysicWorld"
require "src.entities.Hero"
require "src.entities.Zombie"
require "src.entities.Bullet"
local Vision = require "src.misc.Vision"
local MapGen = require 'src.mapgen.MapGen'

Game = Gamestate.new()

local color = { 255, 255, 255, 0 }

LEVEL = 1


local center = {
  x = love.graphics.getWidth() / 2,
  y = love.graphics.getHeight() / 2
}

local bigFont   =   love.graphics.newFont(32)
local smallFont =   love.graphics.newFont(16)
local m2pix = 		20
local world =		PhysicWorld( 0, 0, m2pix )
local stage = 		Stage(world)

local checkEntities = function(a, b, s1, s2, foo)
	if (a.entitytype == s1 and b.entitytype == s2) then
		foo(a,b)
	elseif (a.entitytype == s2 and b.entitytype == s1) then
		foo(b,a)
	end
end

local destroyFirst = function(e1,e2) e1.dead = true end
local damageFirst = function(howmuch)
	return function(e1, e2)
		e1.health = e1.health - howmuch
		if e1.health <= 0 then
			e1.dead = true
		end
	end
end

local beginContact = function(a,b,coll)
	local aent = a:getBody():getUserData()
	local bent = b:getBody():getUserData()
	checkEntities(aent, bent, "bullet", "zombie", destroyFirst)
	checkEntities(aent, bent, "bullet", "wall", destroyFirst)
	checkEntities(aent, bent, "zombie", "bullet", damageFirst(10))
end

local endContact = function(a,b,coll)
end

local preSolve = function(a,b,coll)
end

local postSolve = function(a,b,coll,normalimpulse1,tangentimpulse1,normalimpulse2,tangentimpulse2)
end

world.w:setCallbacks( beginContact, endContact, preSolve, postSolve )

hero = nil
local cam = camera.new(0,0,1,0)

camshake = 0


local directController = function(zombie)
	local v2p = hero.pos - zombie.pos
	local speed = 150
	if v2p:len() > 60 then
		v2p:normalize_inplace()
		zombie.physicbody:setLinearVelocity(v2p.x * speed, v2p.y * speed)
	else
		zombie.physicbody:setLinearVelocity(0,0)
	end
end

local spawnZombieWithDirectController = function(x,y)
	x = x + love.math.random() * 300
	y = y + love.math.random() * 300
	local z = Zombie(stage, x, y, directController)
end

local swarm
local swarms = {}
local spawnZombieSwarm = function(x,y,howmany,teamid,spread)
	local zombies = {}
	spread = spread or 1000
	spread = 50
	for i=1,howmany do
		local px, py;
		px = x + love.math.random() * spread
		py = y + love.math.random() * spread
		table.insert(zombies, Zombie(stage, px,py))
	end

	-- dirty
	swarm = GlobalMind(hero, zombies, teamid)
	for k,z in pairs(zombies) do
		z.controller = z.ai.controller
	end
	return swarm
end

local map
local lastWallID = -1
local buildMap = function()
	for i=1,#map do
		for j=1,#map[1] do
			if map[i][j] == 1 then
				local phb = stage.physicworld:createRectangleBody(i * 128 + 64,j * 128 + 64,128,128,0,"static")
				local posx, posy = phb:getPosition()
				local data = { entitytype = "wall", id=lastWallID, pos=Vector(posx, posy) }
				lastWallID = lastWallID - 1
				local block = GameEntity(stage, 0, 0, nil, phb)
				block.physicbody:setUserData(data)
			end
		end
	end
end

spawnBloodParticle = function (x, y, dx, dy)
	local anim = newAnimation(Image.blood, 4, 4, 1, 1)
	anim:addFrame(0,0,4,4,1)
	local particle = GameEntity(stage, x, y, anim, nil)

	local vec = Vector(dx,dy) * 20
	local tmp = { x = particle.pos.x, y = particle.pos.y }
	timer.tween(0.2, tmp, { y = tmp.y + vec.y}, 'linear',
	function()
		timer.add(1, function() particle.dead=true end)
	end)
	timer.tween(0.2, tmp, { x = tmp.x + vec.x}, 'linear')

	local boing = { y = 0 }
	timer.tween(0.1, boing, {y = 10}, 'out-quad', function()
		timer.tween(0.1, boing, {y = 0}, 'quad')
	end)

	particle.controller = function(self)
		self.pos.x = tmp.x
		self.pos.y = tmp.y - boing.y
	end

end

tefunc = function()
	local myrand = function (spread)
		return (love.math.random(spread)-spread/2)/10
	end
	spawnBloodParticle(hero.pos.x, hero.pos.y, -2 + myrand(20), -1 + myrand(20))
	spawnBloodParticle(hero.pos.x, hero.pos.y, 2 + myrand(20), -1 + myrand(20))
	spawnBloodParticle(hero.pos.x, hero.pos.y, -2, 1)
	spawnBloodParticle(hero.pos.x, hero.pos.y, 2, 1)
end

function SpawnFourBloodParticle(pos)
	local myrand = function (spread)
		return (love.math.random(spread)-spread/2)/10
	end
	--spawnBloodParticle(pos.x, pos.y, -2 + myrand(20), -1 + myrand(20))
	spawnBloodParticle(pos.x, pos.y, 2 + myrand(20), -1 + myrand(20))
	spawnBloodParticle(pos.x, pos.y, -2 + myrand(20), 1 + myrand(20))
	spawnBloodParticle(pos.x, pos.y, 2 + myrand(20), 1 + myrand(20))
end

local aisliders = {
	friendSeparationSlider = { value = 5, min = 0.5, max = 20, pos = {100, 200} },
	wallSeparationSlider = { value = 5, min = 0.5, max = 20 },
	alignmentSlider = { value = 10, min = 0.5, max = 20 },
	cohesionSlider = { value = 1, min = 0.5, max = 20 },
	objectiveSlider = { value = 1, min = 0, max = 20 },
	thurstSlider = { value = 250, min = 50, max = 500 }
}

haswon = false
resethero = true
local nextFloor = nil
function Game:enter()
	haswon = LEVEL == 5
	if haswon then
		haswon = false
		resethero = true
		LEVEL = 1
		Gamestate.switch(WinScreen)
	end
	map = MapGen:generate2(25,20, LEVEL)
	for k,v in pairs(stage.objects) do
		v.dead = true
	end
	local herowasdead, herokills, herohealth
	herowasdead = true
	if hero ~= nil then
		herowasdead = hero.dead
		herokills = hero.kills
		herohealth = hero.health
	end
	stage:reset()
	--GameEntity(stage,0,0,anim,nil)
	local nextpos = MapGen:getRandomValidTile(map)
	local anim = newAnimation(Image.nextfloor, 48, 48, 1, 1)
	nextFloor = GameEntity(stage, (nextpos.x+0.25) * 128, (nextpos.y+0.25)*128, anim, nil)
	local heropos = MapGen:getRandomValidTile(map)
	hero = Hero(stage,(heropos.x + 0.5) * 128,(heropos.y+0.5) * 128,world)
	if not resethero then
		print("presetin")
		hero.kills = herokills
		hero.health = herohealth
	end
	timer.add(2, tefunc)
	--spawnBloodParticle(hero.pos.x, hero.pos.y, 1, 1)
	buildMap()
	local pos = MapGen:getRandomValidTile(map)
	pos.x = pos.x + 0.5
	pos.y = pos.y + 0.5
	pos = MapGen:getRandomNearbyValidTile(map, hero.pos)
	--spawnZombieSwarm(pos.x * 128, pos.y * 128,30,"ZomboidTeam", 100)
	swarms = {}
	table.insert(swarms, SpawnNearbySwarm())
	table.insert(swarms, SpawnNearbySwarm())
	Vision:init(stage, hero, false)
	--[[
	for i=1,100 do
		spawnZombieWithDirectController(hero.pos.x+50,hero.pos.y+50)
	end
	]]--
end

function SpawnNearbySwarm()
	local pos = MapGen:getRandomNearbyValidTile(map, hero.pos)
	return spawnZombieSwarm((pos.x+0.5) * 128, (pos.y+0.5) * 128,LEVEL*7,"ZomboidTeam", 100)
end

GUI_ENABLED = false

function Game:update( dt )
	if (hero.pos - nextFloor.pos):len() < 60 then
		resethero = false
		LEVEL = LEVEL + 1
		if LEVEL > 4 then
			level = 4
		end
		Gamestate.switch(Game)
	end
	if hero.health <= 0 then
		resethero = true
		LEVEL = 1
		Gamestate.switch(DeadScreen)
	end
	Vision:computeVision()
	timer.update(dt)
	stage:update(dt)

	for k,swarm in pairs(swarms) do
		swarms[k]:step()
		if swarms[k].dead then
			--SpawnNearbySwarm()
			swarms[k] = SpawnNearbySwarm()
			swarms[k].dead = false
		end
	end

	local x,y = hero.physicbody:getPosition()
	cam:lookAt(x,y)
	if GUI_ENABLED then
	if gui.Button{text = "Go back"} then
		timer.clear()
		Gamestate.switch(Menu)
	end
    gui.group.push{grow = "down", pos = {20, 200}}
    	gui.Label{ text="friend separation", pos={0, 0}}
		gui.Slider{ info = aisliders.friendSeparationSlider }
    	gui.Label{ text="wall separation", pos={0, 0}}
		gui.Slider{ info = aisliders.wallSeparationSlider }
    	gui.Label{ text="alignment", pos={0, 0}}
		gui.Slider{ info = aisliders.alignmentSlider }
    	gui.Label{ text="cohesion", pos={0, 0}}
		gui.Slider{ info = aisliders.cohesionSlider }
    	gui.Label{ text="objective", pos={0, 0}}
		gui.Slider{ info = aisliders.objectiveSlider }
    	gui.Label{ text="thurst", pos={0, 0}}
		gui.Slider{ info = aisliders.thurstSlider }
		if gui.Button{text = "Apply!"} then
			swarm:updateAllParams({
				wallSeparation = aisliders.wallSeparationSlider.value,
				alignment = aisliders.alignmentSlider.value,
				cohesion = aisliders.cohesionSlider.value,
				objective = aisliders.objectiveSlider.value,
				friendSeparation = aisliders.friendSeparationSlider.value,
				thurst = aisliders.thurstSlider.value,
			})
		end
		if gui.Button{text = "Respawn!"} then
			spawnZombieSwarm(#map/2 * 128, #map[1]/2*128,30,"ZomboidTeam", 100)
		end
    gui.group.pop()
end
end

local mouseData = {
	leftButton = false,
	x = 0,
	y = 0
}

function Game:mousepressed(x, y, button)
	if button == "l" then
		hero.input.shoot = true
	end
end

function Game:mousereleased(x, y, button)
	if button == "l" then
		hero.input.shoot = false
	end
end

debugRays = {}

local visioncanvas = love.graphics.newCanvas(love.window.getWidth(),love.window.getHeight())
local scenecanvas = love.graphics.newCanvas(love.window.getWidth(),love.window.getHeight())
local finalcanvas = love.graphics.newCanvas(love.window.getWidth(),love.window.getHeight())

function Game:draw()
	love.graphics.setCanvas(scenecanvas)
  love.graphics.setColor({255,255,255,255})
  camshake = camshake * 0.9
  cam:lookAt(
  	cam.x + (love.math.random() - 0.5) * camshake,
  	cam.y + (love.math.random() - 0.5) * camshake
	)
  cam:draw( function()
	local tilesize = 128
	  love.graphics.setColor(0x9b,0xad,0xb7,255)
  	  love.graphics.rectangle("fill", 0, 0, #map * tilesize, #map[1] * tilesize)
  	  local xstart, ystart, xend, yend
  	  xstart = math.floor(math.max(1,hero.pos.x/128 - 1))
  	  ystart = math.floor(math.max(1,hero.pos.y/128 - 1))
  	  xend =   math.floor(math.min(#map, hero.pos.x/128 + 1))
  	  yend =   math.floor(math.min(#map, hero.pos.y/128 + 1))
	  for i=xstart,xend do
		  for j=ystart,yend do
			  if map[i][j] == 1 then
				  --love.graphics.setColor(0x3f,0x3f,0x74,255)
				  love.graphics.setColor(0,0,0,255)
				  love.graphics.rectangle("fill", i * tilesize, j * tilesize, tilesize, tilesize)
				  --[[
			  elseif map[i][j] == 2 then
				  love.graphics.setColor(64,150,40,255)
				  love.graphics.rectangle("fill", i * tilesize, j * tilesize, tilesize, tilesize)
			  elseif map[i][j] == 3 then
				  love.graphics.setColor(200,150,30,255)
				  love.graphics.rectangle("fill", i * tilesize, j * tilesize, tilesize, tilesize)
				  ]]--
			  end
		  end
	  end
	  stage:draw()
	  --swarm:debugDraw()
	  --for k,v in pairs(debugRays) do
		--love.graphics.line(v.o.x, v.o.y, v.dir.x , v.dir.y)
	  --end
	  debugRays = {}
	  love.graphics.setColor(255,0,255,255)
	  love.graphics.point(hero.pos.x, hero.pos.y)
  end)

  love.graphics.setBlendMode('alpha')
  love.graphics.setCanvas(visioncanvas)
  cam:draw( function() Vision:draw() end )

  love.graphics.setCanvas(finalcanvas)
  love.graphics.setShader()
  love.graphics.draw(scenecanvas)
  love.graphics.setShader(Vision.visionShader)
  love.graphics.draw(visioncanvas)
  love.graphics.setShader()
  love.graphics.setCanvas()

  love.graphics.draw(finalcanvas)
  love.graphics.setFont(smallFont)
  love.graphics.setColor(color)
  gui.core.draw()
  love.graphics.setColor({255,0,0,255})
  love.graphics.print("Current FPS: "..tostring(love.timer.getFPS( )), 10, 50)
  love.graphics.print("KILLS: "..tostring(hero.kills), 10, 100)
  love.graphics.print("FLOOR: "..tostring(LEVEL), 10, 150)
  if GUI_ENABLED then
  love.graphics.print("Num walls detected by swarm: " ..tostring(swarm.numwalls), 10, 100)
  end

  love.graphics.setColor({140,0,0,255})
  if hero.health < 0 then
  	  hero.health = 0
  end
  love.graphics.rectangle("fill", 100,700,hero.health* 8,20)
end
