
local Class         = require (LIBRARYPATH.."hump.class"	)

require "src.entities.GameEntity"
require "src.entities.Bullet"
require (LIBRARYPATH.."AnAL")

Hero = Class {
  init = function(self, stage, x, y, world)
	local anim = newAnimation(Image.hero_sheet_4x,44,88,1,1)
	anim:addFrame(0,0,44,88,1)
	local phb = world:createPlayer(x, y)
  	self = GameEntity.init( self, stage, x, y, anim, phb )
  	return self
  end,
  keyinput = {
	up = false,
	down = false,
	left = false,
	right = false,
	shoot = false
  },
  update = function(self,dt)

	self.keyinput.up = love.keyboard.isDown("w")
	self.keyinput.down = love.keyboard.isDown("s")
	self.keyinput.left = love.keyboard.isDown("a")
	self.keyinput.right = love.keyboard.isDown("d")
	self.keyinput.shoot = love.keyboard.isDown("r")

	local dx, dy
	dx = 0
	dy = 0
	if self.keyinput.up then
		dy = -1
	elseif self.keyinput.down then
		dy = 1
	end

	if self.keyinput.right then
		dx = 1
	elseif self.keyinput.left then
		dx = -1
	end

	if self.keyinput.shoot then
		self:shoot(100, 0)
	end

	self.physicbody:setLinearVelocity(dx*300, dy*300)
	self.physicbody:setAngle(0)
	GameEntity.update(self,dt)
  end,
  shoot = function(self, vx, vy)
	Bullet(self.stage, self.pos.x, self.pos.y, vx, vy)
  end
}

Hero:include(GameEntity)
