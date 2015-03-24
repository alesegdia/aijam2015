
local Class = require (LIBRARYPATH.."hump.class")

require "src.entities.GameEntity"
require (LIBRARYPATH.."AnAL")

Bullet = Class {
	init = function(self, stage, x, y, xspeed, yspeed)
		local anim = newAnimation(Image.shoot4x,8,4,1,1)
		anim:addFrame(0,0,8,4,1)
		local phb = stage.physicworld:createRectangleBody(x, y, 8, 4)
		self = GameEntity.init( self, stage, x, y, anim, phb )
		self.xspeed = xspeed
		self.yspeed = yspeed
	end,
	update = function(self, dt)
		self.physicbody:setLinearVelocity(self.xspeed, self.yspeed)
		GameEntity.update(self, dt)
	end
}

Bullet:include(GameEntity)
