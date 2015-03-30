
local Class         = require (LIBRARYPATH.."hump.class"	)
local Vector        = require (LIBRARYPATH.."hump.vector"	)

require "src.entities.GameEntity"
require (LIBRARYPATH.."AnAL")


Zombie = Class {
  init = function(self, stage, x, y, controller)
	local anim = newAnimation(Image.zombie_sheet_4x,40,48,1,1)
	anim:addFrame(0,0,40,48,1)
	local phb = stage.physicworld:createZombie(x, y)
	phb:setSleepingAllowed(false)
  	self = GameEntity.init( self, stage, x, y, anim, phb )
  	self.controller = controller or function(self) print("im dumb heh") end
  	self.entitytype = "zombie"
  	self.health = 10
  	phb:setUserData(self)
	self.rightq = love.graphics.newQuad( 0, 0, 44, 88, Image.zombie_sheet_4x:getDimensions())
	self.leftq = love.graphics.newQuad( 40, 0, 40, 88, Image.zombie_sheet_4x:getDimensions())
  	return self
  end,

  update = function(self,dt)

	self:controller()
	self.physicbody:setAngle(0)
	GameEntity.update(self,dt)
  end,

  draw = function(self)
	if hero.pos.x < self.pos.x then
	  	  love.graphics.draw(Image.zombie_sheet_4x, self.leftq, self.pos.x, self.pos.y, 0, 1, 1, Image.hero_sheet_4x:getWidth()/4, Image.hero_sheet_4x:getHeight()/2)
	else
	  	  love.graphics.draw(Image.zombie_sheet_4x, self.rightq, self.pos.x, self.pos.y, 0, 1, 1, Image.hero_sheet_4x:getWidth()/4, Image.hero_sheet_4x:getHeight()/2)
	end
	GameEntity.draw(self)
  end
}

Zombie:include(GameEntity)
