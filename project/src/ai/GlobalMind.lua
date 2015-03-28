
local Class = require (LIBRARYPATH.."hump.class")

require 'src.entities.Zombie'
require 'src.ai.IndividualMind'

GlobalMind = Class {

	minions = {},

	updateAllParams = function(self, params)
		for k,v in pairs(self.minions) do
			v.params = params
		end
	end,

	init = function(self, hero, zombies, teamid)
		self.teamid = teamid
		self.hero = hero
		self.dead = false
		self.minions = {}
		self.numMinions = 0
		for k,v in pairs(zombies) do
			self.minions[v.id] = IndividualMind(self,v)
			self.numMinions = self.numMinions + 1
		end
		self.lastguyindex = 0
		self.numwalls = 0

		-- -1: infinite
		self.updatesPerFrame = -1
	end,

	step = function(self)
		self.dead = self.numMinions == 0
		self.numwalls = 0
		if self.updatesPerFrame > 0 then
			for i=1,self.updatesPerFrame do
				self.lastguyindex = (self.lastguyindex+1) % #self.minions + 1
				local individual = self.minions[self.lastguyindex]
				individual:computeInfluence()
				self.numwalls = self.numwalls + individual.numwalls
				--individual.pawn.physicbody:setLinearVelocity()
				if individual.pawn.dead then
					table.insert(todel, individual.pawn.id)
				end
				print(".")
			end
			print("END")
		else
			local todel = {}
			for k,individual in pairs(self.minions) do
				individual:computeInfluence()
				self.numwalls = self.numwalls + individual.numwalls
				--individual.pawn.physicbody:setLinearVelocity()
				if individual.pawn.dead then
					table.insert(todel, individual.pawn.id)
				end
			end
			for k,v in pairs(todel) do
				self.minions[v] = nil
				self.numMinions = self.numMinions - 1
			end
		end
	end,

	debugDraw = function(self)
		for k, individual in pairs(self.minions) do
			individual:debugDraw()
		end
	end

}
