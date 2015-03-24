
local Class = require (LIBRARYPATH.."hump.class")

require "src.entities.GameEntity"
require (LIBRARYPATH.."AnAL")
local Vector        = require (LIBRARYPATH.."hump.vector"	)

Bullet = Class {
	init = function(self, stage, x, y, xspeed, yspeed)
		local anim = newAnimation(Image.shoot4x,8,4,1,1)
		anim:addFrame(0,0,8,4,1)
		self = GameEntity.init( self, stage, x, y, anim, stage.physicworld:createBullet(x,y) )
		self.xspeed = xspeed
		self.yspeed = yspeed
		local v1 = Vector(1,0)
		local v2 = Vector(xspeed, yspeed)
		v2:normalize_inplace()
		self.angle = v1:angleTo(v2)
		GameEntity.update(self, 0)
		self.entitytype = "bullet"
		return self
	end,
	update = function(self, dt)
		self.physicbody:setLinearVelocity(self.xspeed, self.yspeed)
		self.physicbody:setAngle(-self.angle)
		GameEntity.update(self, dt)
	end
}

Bullet:include(GameEntity)
