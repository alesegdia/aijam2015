
local Class = require (LIBRARYPATH.."hump.class")

require 'src.entities.Zombie'
require 'src.ai.IndividualMind'

GlobalMind = Class {

	minions = {},

	init = function(self, hero, zombies, teamid)
		self.teamid = teamid
		-- spawn individuals
		self.minions = {}
		for k,v in pairs(zombies) do
			self.minions[k] = IndividualMind(self,v)
		end
	end,

	step = function(self)
		-- Vectores de influencia:
		-- * Separación (gira para evitar obstáculos y vecinos locales)
		-- * Alineación (apuntar hacia donde apunta la media)
		-- * Cohesión (giro hacia la posición media)
		-- * Objetivo Hero? mayble laterakfakjsdfjasjdjjfjsdjfa
		-- ASSUMING CONTROL
		-- Iterate twice:
		-- 1. Reset steers, sum positions, perform perception
		-- 2. With sum, get centroid and calculate final steering, then apply steering
		local mid = Vector(0,0)
		for k, v in pairs(self.minions) do

			v:resetSteer()

			mid.x = mid.x + v.zombie.pos.x
			mid.y = mid.y + v.zombie.pos.y

			v:perceive()

		end
		mid.x = mid.x / #self.minions
		mid.y = mid.y / #self.minions

		for k, v in pairs(self.minions) do
			v:applySteer()
		end
	end

}
