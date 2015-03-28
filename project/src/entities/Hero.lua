
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
  	self.shootRate = 0.2
  	self.nextShoot = love.timer.getTime() + self.shootRate
  	self.entitytype = "hero"
  	self.health = 20
  	self.deltaboing = Vector(0,0)
	phb:setUserData(self)
	self.lastBoingFinished = true
	self.isHurting = 255
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

	if dx ~= 0 or dy ~= 0 then
		if self.lastBoingFinished then
			self.lastBoingFinished = false
			self.boingtween = timer.tween(0.1, self.deltaboing, { y = -10 }, 'out-quad', function()
				timer.tween(0.1, self.deltaboing, { y = 0 }, 'quad', function() self.lastBoingFinished = true end)
			end)
		end
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

  	  if self.isHurting < 255 then
  	  	  self.isHurting = self.isHurting+5
	  end
	GameEntity.update(self,dt)
	self.pos.x = self.pos.x + self.deltaboing.x
	self.pos.y = self.pos.y + self.deltaboing.y
  end,

  draw = function(self)
  	  if self.isHurting < 0 then self.isHurting = 0 end
  	  if self.isHurting > 255 then self.isHurting = 255 end
		love.graphics.setColor(255,self.isHurting,self.isHurting,255)
	  GameEntity.draw(self)
	  love.graphics.setColor(255,255,255,255)
  end,

  shoot = function(self, vx, vy)
	love.audio.play(Sfx.Explosion22)
  	  self.physicbody:applyForce(-vx*50, -vy*50)
  	  camshake = camshake + 20
  	  self.stage.physicworld:raycastShotgun(self.pos, Vector(vx,vy), math.rad(20), 10,
	  function(ent)
		  ent.health = ent.health - 5
		  if ent.health <= 0 then ent.dead = true end
		  SpawnFourBloodParticle(ent.pos)
	  end, self)
  	  --[[
	  local finalpos = self.pos + Vector(0,0)
	  Bullet(self.stage, finalpos.x, finalpos.y, vx, vy)
	  --]]
  end

}

Hero:include(GameEntity)
