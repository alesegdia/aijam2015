--
--  Game
--

local Gamestate     = require (LIBRARYPATH.."hump.gamestate")
local gui       = require( LIBRARYPATH.."Quickie"           )
local camera = require (LIBRARYPATH.."hump.camera")
local timer = require (LIBRARYPATH.."hump.timer")
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

local beginContact = function(a,b,coll)
	local aent = a:getBody():getUserData()
	local bent = b:getBody():getUserData()
	local destroyFirst = function(e1,e2) e1.dead = true end
	local damageFirst = function(howmuch)
		return function(e1, e2)
			e1.health = e1.health - howmuch
			if e1.health <= 0 then
				e1.dead = true
			end
		end
	end
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

local spawnZombie = function(x,y)
	x = x + love.math.random() * 300
	y = y + love.math.random() * 300
	local z = Zombie(stage, x, y, directController)
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

function Game:enter()
	for k,v in pairs(stage.objects) do
		v.dead = true
	end
	local anim = newAnimation(Image.map8x, 1600, 1280, 1, 1)
	--GameEntity(stage,0,0,anim,nil)
	hero = Hero(stage,map.size.w/2 * 128,map.size.h/2 * 128,world)
	anim:addFrame(0,0,1600,1280,1)
	buildMap()
	for i=1,100 do
		spawnZombie(hero.pos.x+50,hero.pos.y+50)
	end
end

function Game:update( dt )
	timer.update(dt)
	stage:update(dt)
	cam:lookAt(hero.pos.x, hero.pos.y)
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


function Game:draw()
  love.graphics.setFont(smallFont)
  love.graphics.setColor(color)
  gui.core.draw()
  love.graphics.setColor({255,0,0,255})
  love.graphics.print("Current FPS: "..tostring(love.timer.getFPS( )), 10, 50)
  love.graphics.setColor({255,255,255,255})
  GameEntity.update(hero, 0)
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
  end)
end
