
local Class = require (LIBRARYPATH.."hump.class")

require 'src.entities.Zombie'
require 'src.ai.IndividualMind'

GlobalMind = Class {

	minions = {},

	updateAllParams = function(self, params)
		for k,v in pairs(self.minions) do
			v.influenceWeight = params
		end
	end,

	init = function(self, hero, zombies, teamid)
		self.teamid = teamid
		self.hero = hero
		self.minions = {}
		for k,v in pairs(zombies) do
			self.minions[v.id] = IndividualMind(self,v)
		end
		self.lastguyindex = 0
		self.numwalls = 0
	end,

	step = function(self)
		self.lastguyindex = (self.lastguyindex+1) % #self.minions + 1
		local individual = self.minions[self.lastguyindex]
		self.numwalls = 0
		local todel = {}
		for k,individual in pairs(self.minions) do
			individual:computeInfluence()
			individual:decideSteerBasedOnInfluence()
			individual:applySteer()
			self.numwalls = self.numwalls + individual.numwalls
			--individual.pawn.physicbody:setLinearVelocity()
			if individual.pawn.dead then
				table.insert(todel, individual.pawn.id)
			end
		end
		for k,v in pairs(todel) do
			self.minions[v] = nil
		end
	end,

	debugDraw = function(self)
		for k, individual in pairs(self.minions) do
			individual:debugDraw()
		end
	end

}
