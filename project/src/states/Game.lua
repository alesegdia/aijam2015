--
--  Game
--

local Gamestate     = require (LIBRARYPATH.."hump.gamestate")
local gui       = require( LIBRARYPATH.."Quickie"           )
local camera = require (LIBRARYPATH.."hump.camera")
timer = require (LIBRARYPATH.."hump.timer")
local Vector        = require (LIBRARYPATH.."hump.vector"	)
local tween         = timer.tween

require "src.entities.Stage"
require "src.entities.GameEntity"
require "src.entities.PhysicWorld"
require "src.entities.Hero"
require "src.entities.Zombie"
require "src.entities.Bullet"
local MapGen = require 'src.mapgen.MapGen'

Game = Gamestate.new()

local color = { 255, 255, 255, 0 }


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

local hero = nil
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
local spawnZombieSwarm = function(x,y,howmany,teamid,spread)
	local zombies = {}
	spread = spread or 1000
	for i=1,howmany do
		x = x + love.math.random() * spread
		y = y + love.math.random() * spread
		table.insert(zombies, Zombie(stage, x, y))
	end

	-- dirty
	swarm = GlobalMind(hero, zombies, teamid)
	for k,z in pairs(zombies) do
		z.controller = z.ai.controller
	end
end

local map = MapGen(25,20)
local buildMap = function()
	for i=1,map.size.w do
		for j=1,map.size.h do
			if map.data[i][j] == 0 then
				local phb = stage.physicworld:createRectangleBody(i * 128 + 64,j * 128 + 64,128,128,0,"static")
				local data = { entitytype = "wall" }
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

function Game:enter()
	for k,v in pairs(stage.objects) do
		v.dead = true
	end
	local anim = newAnimation(Image.map8x, 1600, 1280, 1, 1)
	--GameEntity(stage,0,0,anim,nil)
	hero = Hero(stage,map.size.w/2 * 128,map.size.h/2 * 128,world)
	timer.add(2, tefunc)
	--spawnBloodParticle(hero.pos.x, hero.pos.y, 1, 1)
	anim:addFrame(0,0,1600,1280,1)
	buildMap()
	spawnZombieSwarm(map.size.w/2 * 128, map.size.h/2*128,1,"ZomboidTeam", 1)

	--[[
	for i=1,100 do
		spawnZombieWithDirectController(hero.pos.x+50,hero.pos.y+50)
	end
	]]--
end


function Game:update( dt )
	timer.update(dt)
	stage:update(dt)
	local x,y = hero.physicbody:getPosition()
	cam:lookAt(x,y)
	if gui.Button{text = "Go back"} then
		timer.clear()
		Gamestate.switch(Menu)
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


function Game:draw()
  love.graphics.setFont(smallFont)
  love.graphics.setColor(color)
  gui.core.draw()
  love.graphics.setColor({255,0,0,255})
  love.graphics.print("Current FPS: "..tostring(love.timer.getFPS( )), 10, 50)
  love.graphics.setColor({255,255,255,255})
  camshake = camshake * 0.9
  cam:lookAt(
  	cam.x + (love.math.random() - 0.5) * camshake,
  	cam.y + (love.math.random() - 0.5) * camshake
	)
  cam:draw( function()
	local tilesize = 128
	  love.graphics.setColor(0x9b,0xad,0xb7,255)
  	  love.graphics.rectangle("fill", 0, 0, map.size.w * tilesize, map.size.h * tilesize)
	  for i=1,map.size.w do
		  for j=1,map.size.h do
			  if map.data[i][j] == 0 then
				  love.graphics.setColor(0x3f,0x3f,0x74,255)
				  love.graphics.rectangle("fill", i * tilesize, j * tilesize, tilesize, tilesize)
			  end
		  end
	  end
	  stage:draw()
	  swarm:debugDraw()
	  --[[
	  for k,v in pairs(debugRays) do
		--love.graphics.line(v.o.x, v.o.y, v.o.x + v.dir.x * 10, v.o.y + v.dir.y * 10)
	  end
	  ]]--
  end)
end
