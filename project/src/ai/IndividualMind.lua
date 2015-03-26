
local Class = require (LIBRARYPATH.."hump.class")

require 'src.entities.Zombie'

IndividualMind = Class {

	init = function(self, globalmind, zombie)
		self.globalmind = globalmind
		self.pawn = pawn
		self.forward = Vector(0,0)
	end,

	step = function(self)

	end

}
