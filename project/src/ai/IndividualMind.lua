
local Class = require (LIBRARYPATH.."hump.class")

require 'src.entities.Zombie'

IndividualMind = Class {

	init = function(self, globalmind, zombie)
		self.globalmind = globalmind
		self.pawn = pawn
		self.forward = Vector(0,0)
		self.thurst = 0
		self.steer = 0
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

	perceive = function(self)
		self.perceived = {}
		-- perform raycast
		local physicsResult = ( function () return {} end ) ()
		for k, ent in pairs(physicsResult) do
			local dist2 = ent.zombie.pos:dist2( self.zombie.pos )
			if ent.entitytype == "zombie" then
				if ent.teamid == self.globalmind.teamid then
					if dist2 < 10000 then
						-- influences friend separation
					end
					if dist2 < 50000 then
						-- influences alineation
						-- influences cohesion
					end
				else
					if dist2 < 50000 then
						-- influences strange zombie separation
					end
				end
			elseif ent.entitytype == "wall" then
				if dist2 < 50000 then
					-- influences wall separation
				end
			end
		end
	end
}
