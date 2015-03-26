
local Class = require (LIBRARYPATH.."hump.class")

require 'src.entities.Zombie'
require 'src.ai.IndividualMind'

GlobalMind = Class {

	minions = {},

	init = function(self, hero, zombies)
		self.minions = {}
		for k,v in pairs(zombies) do
			self.minions[k] = IndividualMind(self,v)
		end
	end,

	step = function(self)
		-- Vectores de influencia:
		-- * Separación (gira para evitar vecinos locales)
		-- * Alineación (giro hacia posición media)
		-- * 
		local mid = Vector(0,0)
		for k, v in pairs(self.minions) do
			mid.x = mid.x + v.zombie.pos.x
			mid.y = mid.y + v.zombie.pos.y
		end
		mid.x = mid.x / #self.minions
		mid.y = mid.y / #self.minions
		for k, v in pairs(self.minions) do
			v:step()
		end
	end

}
