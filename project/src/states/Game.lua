--
--  Game
--

local Gamestate     = require (LIBRARYPATH.."hump.gamestate")
local gui       = require( LIBRARYPATH.."Quickie"           )
local timer = require (LIBRARYPATH.."hump.timer")
local tween         = timer.tween

require "src.entities.Stage"
require "src.entities.GameEntity"
require "src.entities.PhysicWorld"

Game = Gamestate.new()

local color = { 255, 255, 255, 0 }

local center = {
  x = love.graphics.getWidth() / 2,
  y = love.graphics.getHeight() / 2
}

local bigFont   =   love.graphics.newFont(32)
local smallFont =   love.graphics.newFont(16)
local m2pix = 		32
local world =		PhysicWorld( 0, 200, m2pix )
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

local MakeTestEntity = function(x,y)
  local anim = newAnimation(Image.tesprite,32,32,0.2,5)
  anim:addFrame(0,0,32,32,0.5)
  anim:addFrame(0,32,32,32,0.2)
  anim:addFrame(32,0,32,32,0.2)
  anim:addFrame(32,32,32,32,0.2)
  anim:addFrame(64,32,32,32,0.2)
  GameEntity( stage, x, y, anim, world:createSphereBody(x,y,10/32,10) )
  --GameEntity( stage, world, x, y, anim, world:createRectangleBody(x,y,5/32,5/32,10) )
end

local left = false
local right = false
local MakeCube = function(x,y)
  local anim = newAnimation(Image.tesprite,32,32,0.2,5)
  anim:addFrame(0,0,32,32,0.5)
  anim:addFrame(0,32,32,32,0.2)
  anim:addFrame(32,0,32,32,0.2)
  anim:addFrame(32,32,32,32,0.2)
  anim:addFrame(64,32,32,32,0.2)
  local phb = world:createBody(x,y,0,"kinematic")
  world:addRectFixture( phb, 0, 130, 600, 10, 0 )
  world:addRectFixture( phb, -300, 0, 10, 300, 0 )
  world:addRectFixture( phb, 300, 0, 10, 300, 0 )
  local ent = GameEntity( stage, x, y, anim, phb ) --world:createCube(x,y))
  ent.controller = function(self)
	local ang = 0
	if left then ang = -1 end
	if right then ang = 1 end
	self.physicbody:setAngularVelocity(ang)
  end
end


function Game:enter()
  for k,v in pairs(stage.objects) do
	v.dead = true
  end
  color = { 255, 255, 255, 0 }
  tween(4, color, { 255, 255, 0, 255 }, 'bounce' )
  for i=1,300 do
  	MakeTestEntity(300+i*1,250)
  end
  MakeCube(400,400)
end

function Game:update( dt )
  timer.update(dt)
  stage:update(dt)
  if gui.Button{text = "Go back"} then
	timer.clear()
	Gamestate.switch(Menu)
  end
  left = false
  right = false
  if love.keyboard.isDown("a") then left = true end
  if love.keyboard.isDown("d") then right = true end
end

function Game:draw()
  love.graphics.setFont(bigFont)
  love.graphics.setColor(color)
  love.graphics.rectangle("fill", 0, 0, center.x*2, color[4])
  love.graphics.print("You lost the game.", center.x, center.y)
  love.graphics.setFont(smallFont)
  stage:draw()
  gui.core.draw()
  love.graphics.setColor({255,0,0,255})
  love.graphics.print("Current FPS: "..tostring(love.timer.getFPS( )), 10, 50)
end
