
local Class         = require (LIBRARYPATH.."hump.class"	)
local Vector        = require (LIBRARYPATH.."hump.vector"	)

require "src.entities.GameEntity"
require (LIBRARYPATH.."AnAL")


Zombie = Class {
  init = function(self, stage, x, y, controller)
	local anim = newAnimation(Image.zombie_sheet_4x,40,48,1,1)
	anim:addFrame(0,0,40,48,1)
	local phb = stage.physicworld:createZombie(x, y)
  	self = GameEntity.init( self, stage, x, y, anim, phb )
  	self.controller = controller or function(self) print("im dumb heh") end
  	self.entitytype = "zombie"
  	self.health = 10
  	phb:setUserData(self)
  	return self
  end,

  update = function(self,dt)

	self:controller()
	self.physicbody:setAngle(0)
	GameEntity.update(self,dt)
  end
}

Zombie:include(GameEntity)
