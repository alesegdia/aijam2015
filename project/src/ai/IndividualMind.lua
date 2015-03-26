
local Class = require (LIBRARYPATH.."hump.class")
local Vector        = require (LIBRARYPATH.."hump.vector"	)

require 'src.entities.Zombie'

IndividualMind = Class {

	init = function(self, globalmind, pawn)
		self.globalmind = globalmind
		self.pawn = pawn
		self.forward = Vector(1,0)
		self.thurst = 100
		self.steer = 0

		self.pawn.ai = self

		-- Vectores de influencia:
		-- * Separación (gira para evitar obstáculos y vecinos locales)
		-- * Alineación (apuntar hacia donde apunta la media)
		-- * Cohesión (giro hacia la posición media)
		-- * Objetivo Hero?

		self.influenceWeight = {
			separation = 1,
			alignment = 1,
			cohesion = 1,
			objective = 1
		}
		self.influenceVecs = {
			separation = Vector(0,0),
			alignment = Vector(0,0),
			cohesion = Vector(0,0),
			objective = Vector(0,0)
		}
	end,

	resetSteer = function(self)
		self.steer = 0
	end,

	applySteer = function(self)
	end,

	controller = function(pawn)
		pawn.physicbody:setLinearVelocity(pawn.ai.forward.x * pawn.ai.thurst, pawn.ai.forward.y * pawn.ai.thurst)
	end,

	resetInfluence = function(self)
		for k,v in pairs(self.influenceVecs) do
			v.x, v.y = 0, 0
		end
	end,

	computeInfluence = function(self)
		self:resetSteer()
		self:resetInfluence()
		self.perceived = {}
		-- perform raycast
		local physicsResult = self.pawn.stage.physicworld:raycastZombiePerception(self.pawn, self.forward, 360)
		local sumAngle = 0
		local numAngles = 0
		for k, hit in pairs(physicsResult) do
			local ent = hit.ent
			local diff = hit.point - self.pawn.pos
			local len = diff:len()
			if ent.entitytype == "zombie" then
				print("zombie")
				if ent.teamid == self.globalmind.teamid then
					if len < 200 then
						-- influences friend separation
						self.influenceVecs.separation.sum_inplace( -diff * (1/len) )
					elseif len > 200 and len < 500 then
						-- influences cohesion
					end
					if len < 500 then
						-- influences alignment
						assert(ent.ai, "Entity doesn't have an individual mind.")
						sumAngle = sumAngle + ent.physicbody:getAngle()
						numAngles = numAngles + 1
					end
				else
					if len < 500 then
						-- influences strange zombie separation
					end
				end
			elseif ent.entitytype == "wall" and len < 100 then
				print(ent.entitytype, "is near")
				local arg = -diff * (0.5/len)
				local vec = Vector(arg.x, arg.y)
				self.influenceVecs.separation:sum_inplace( vec )
			elseif ent.entitytype == "hero" and len < 1000 then
				print(ent.entitytype, "is near")
				local arg = diff * (1/len)
				local vec = Vector(arg.x, arg.y)
				self.influenceVecs.separation:sum_inplace( vec )
			end
		end
		local avgAngle = sumAngle / numAngles
		--self.pawn.ai.forward = pawn.ai.globalmind.hero.pos - pawn.pos
		
		--self.pawn.ai.forward:sum_inplace(
		self.pawn.ai.forward:sum_inplace(self.influenceVecs.separation)
		self.pawn.ai.forward:trim_inplace(1)
		-- apply separation, cohesion and alignment
	end,

	debugDraw = function(self)
		local fwd = self.pawn.pos + self.forward * 20
		love.graphics.line(self.pawn.pos.x, self.pawn.pos.y, fwd.x, fwd.y)
		for k,v in pairs(self.influenceVecs) do
			fwd = self.pawn.pos + v * 20
			love.graphics.line(self.pawn.pos.x, self.pawn.pos.y, fwd.x, fwd.y)

		end
	end,

	decideSteerBasedOnInfluence = function(self)
	
	end
}
