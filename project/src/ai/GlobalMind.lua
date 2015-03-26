
local Class = require (LIBRARYPATH.."hump.class")

require 'src.entities.Zombie'
require 'src.ai.IndividualMind'

GlobalMind = Class {

	minions = {},

	init = function(self, hero, zombies, teamid)
		self.teamid = teamid
		self.hero = hero
		self.minions = {}
		for k,v in pairs(zombies) do
			self.minions[k] = IndividualMind(self,v)
		end
		self.lastguyindex = 0
	end,

	step = function(self)
		self.lastguyindex = (self.lastguyindex+1) % #self.minions + 1
		local individual = self.minions[self.lastguyindex]
			individual:computeInfluence()
			individual:decideSteerBasedOnInfluence()
			individual:applySteer()
			--individual.pawn.physicbody:setLinearVelocity()
	end,

	debugDraw = function(self)
		for k, individual in pairs(self.minions) do
			individual:debugDraw()
		end
	end

}
