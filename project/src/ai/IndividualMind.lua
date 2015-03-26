
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
		self.pawn.physicbody.setAngle(self.pawn.physicbody:getAngle() + self.steer)
	end,

	controller = function(pawn)
		pawn.ai.forward = pawn.ai.globalmind.hero.pos - pawn.pos
		pawn.ai.forward:trim_inplace(1)
		pawn.physicbody:setLinearVelocity(pawn.ai.forward.x * pawn.ai.thurst, pawn.ai.forward.y * pawn.ai.thurst)
	end,

	computeInfluence = function(self)
		self:resetSteer()
		self.perceived = {}
		-- perform raycast
		local physicsResult = self.pawn.stage.physicworld:raycastZombiePerception(self.pawn.pos, 360)
		local sumAngle = 0
		local numAngles = 0
		for k, ent in pairs(physicsResult) do
			local diff = ent.zombie.pos - self.zombie.pos
			local len = diff.len()
			if ent.entitytype == "zombie" then
				if ent.teamid == self.globalmind.teamid then
					if len < 100 then
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
			elseif ent.entitytype == "wall" then
				if len < 500 then
					-- influences wall separation
				end
			end
		end
		local avgAngle = sumAngle / numAngles
		-- apply separation, cohesion and alignment
	end,

	debugDraw = function(self)
		local fwd = self.pawn.pos + self.forward * 20
		print(self.forward)
		love.graphics.line(self.pawn.pos.x, self.pawn.pos.y, fwd.x, fwd.y)
	end,

	decideSteerBasedOnInfluence = function(self)
	
	end
}
