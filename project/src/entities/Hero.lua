
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
  	self.shootRate = 0.5
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

	local vx, vy = self.physicbody:getLinearVelocity()
	local final = Vector(vx + dx * 30, vy + dy * 30)
	final:trim_inplace(300)
	if dx == 0 then
		final.x = final.x * 0.9
	end
	if dy == 0 then
		final.y = final.y * 0.9
	end
	self.physicbody:setLinearVelocity(final.x, final.y)
	self.physicbody:setAngle(0)

	if self.input.shoot and love.timer.getTime() > self.nextShoot then
		self.nextShoot = love.timer.getTime() + self.shootRate
		local x,y = love.mouse.getPosition()
		local vec = Vector(x-1024/2,y-768/2)
		vec:normalize_inplace()
		local speed = 1000
		self:shoot(vec.x * speed, vec.y * speed)
	end

	GameEntity.update(self,dt)
  end,
  shoot = function(self, vx, vy)
  	  self.physicbody:applyForce(-vx*100, -vy*100)
  	  self.stage.physicworld:raycastShotgun(self.pos, Vector(-vx,-vy), 30, 5,
	  function(ent)
		  ent.health = ent.health - 5
		  if ent.health <= 0 then ent.dead = true end
	  end)
	  --[[
	  local finalpos = self.pos + Vector(0,0)
	  Bullet(self.stage, finalpos.x, finalpos.y, vx, vy)
	  --]]
  end

}

Hero:include(GameEntity)
