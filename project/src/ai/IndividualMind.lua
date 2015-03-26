
local Class = require (LIBRARYPATH.."hump.class")

require 'src.entities.Zombie'

IndividualMind = Class {

	init = function(self, globalmind, zombie)
		self.globalmind = globalmind
		self.pawn = pawn
		self.forward = Vector(0,0)
		self.thurst = 0
		self.steer = 0

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

	computeInfluence = function(self)
		self:resetSteer()
		self.perceived = {}
		-- perform raycast
		local physicsResult = ( function () return {} end ) ()
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
		local avgAngle = sumAngle / #physicsResult
		-- apply separation, cohesion and alignment
	end,

	decideSteerBasedOnInfluence = function(self)

	end
}
