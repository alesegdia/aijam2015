
local Class         = require (LIBRARYPATH.."hump.class"	)

require "src.entities.Entity"
require (LIBRARYPATH.."AnAL")

GameEntity = Class {
	init = function(self, stage, x, y, anim, phbody)
		print(stage)
		self = Entity.init(self, stage, x, y)
		self.anim = anim
		self.physicbody = phbody or nil
		self.debug = true
		return self
	end,
	update = function(self,dt)
		self.anim:update(dt)
		if self.physicbody ~= nil then
			self.pos.x = self.physicbody:getX()
			self.pos.y = self.physicbody:getY()
		end
	end,
	draw = function(self)

		love.graphics.setColor({255,255,255,255})
		if self.anim then
			local angle
			if self.physicbody ~= nil then
				angle = self.physicbody:getAngle()
			else
				angle = 0
			end
			self.anim:draw(self.pos.x,self.pos.y,angle,1,1,self.anim:getWidth()/2,self.anim:getHeight()/2)
		end
		if self.debug and self.physicbody ~= nil then
			love.graphics.setColor({255,0,255,255})
			for k,fix in pairs(self.physicbody:getFixtureList()) do
				if fix:getType() == "polygon" then
					love.graphics.polygon("line", self.physicbody:getWorldPoints(fix:getShape():getPoints()))
				elseif fix:getType() == "edge" or fix:getType() == "chain" then
					local x1, y1, x2, y2
					x1,y1,x2,y2 = fix:getShape():getPoints()
					love.graphics.push()
					love.graphics.rotate(self.physicbody:getAngle())
					love.graphics.line(self.pos.x+x1,self.pos.y+y1,self.pos.x+x2,self.pos.y+y2)
					love.graphics.pop()
				else
					local cx, cy = fix:getShape():getPoint()
					love.graphics.circle("line", self.pos.x + cx, self.pos.y + cy, fix:getShape():getRadius(), 20)
				end
			end
		end
	end
}

GameEntity:include(Entity)
