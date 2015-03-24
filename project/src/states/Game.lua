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

local beginContact = function(a,b,coll)
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
	local speed = 300
	if v2p:len() > 60 then
		v2p:normalize_inplace()
		zombie.physicbody:setLinearVelocity(v2p.x * speed, v2p.y * speed)
	else
		zombie.physicbody:setLinearVelocity(0,0)
	end
end

local spawnZombie = function(x,y)
	local z = Zombie(stage, x, y, directController)
end

function Game:enter()
  for k,v in pairs(stage.objects) do
	v.dead = true
  end
  local anim = newAnimation(Image.map8x, 1600, 1280, 1, 1)
  GameEntity(stage,0,0,anim,nil)
  spawnZombie(50,50)
  hero = Hero(stage,10,50,world)
  anim:addFrame(0,0,1600,1280,1)
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
	  stage:draw()
  end)
end
