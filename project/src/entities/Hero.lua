
local Class         = require (LIBRARYPATH.."hump.class"	)
local Vector        = require (LIBRARYPATH.."hump.vector"	)

require "src.entities.GameEntity"
require "src.entities.Bullet"
require (LIBRARYPATH.."AnAL")

Hero = Class {
  init = function(self, stage, x, y, world)
	local anim = newAnimation(Image.hero_sheet_4x,44,88,1,1)
	anim:addFrame(0,0,44,88,1)
	local phb = world:createPlayer(x, y)
  	self = GameEntity.init( self, stage, x, y, anim, phb )
  	self.shootRate = 0.1
  	self.nextShoot = love.timer.getTime() + self.shootRate
  	self.entitytype = "hero"
  	self.health = 20
	phb:setUserData(self)
  	return self
  end,
  input = {
	up = false,
	down = false,
	left = false,
	right = false,
	shoot = false
  },
  update = function(self,dt)

	self.input.up = love.keyboard.isDown("w")
	self.input.down = love.keyboard.isDown("s")
	self.input.left = love.keyboard.isDown("a")
	self.input.right = love.keyboard.isDown("d")

	local dx, dy
	dx = 0
	dy = 0
	if self.input.up then
		dy = -1
	elseif self.input.down then
		dy = 1
	end

	if self.input.right then
		dx = 1
	elseif self.input.left then
		dx = -1
	end

	if self.input.shoot and love.timer.getTime() > self.nextShoot then
		self.nextShoot = love.timer.getTime() + self.shootRate
		local x,y = love.mouse.getPosition()
		local vec = Vector(x-1024/2,y-768/2)
		vec:normalize_inplace()
		local speed = 1000
		self:shoot(vec.x * speed, vec.y * speed)
	end

	self.physicbody:setLinearVelocity(dx*300, dy*300)
	self.physicbody:setAngle(0)
	GameEntity.update(self,dt)
  end,
  shoot = function(self, vx, vy)
  	  local finalpos = self.pos + Vector(0,0)
	Bullet(self.stage, finalpos.x, finalpos.y, vx, vy)
  end
}

Hero:include(GameEntity)
