
local Class = require (LIBRARYPATH.."hump.class")

require 'src.entities.Zombie'
require 'src.ai.IndividualMind'

GlobalMind = Class {

	minions = {},

	init = function(self, hero, zombies, teamid)
		self.teamid = teamid
		self.minions = {}
		for k,v in pairs(zombies) do
			self.minions[k] = IndividualMind(self,v)
		end
	end,

	step = function(self)
		for k, individual in pairs(self.minions) do
			individual:resetSteer()
			individual:computeInfluence()
			individual:decideSteerBasedOnInfluence()
			individual:applySteer()
		end
	end

}
