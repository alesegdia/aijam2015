
local Class = require (LIBRARYPATH.."hump.class")
local Vector        = require (LIBRARYPATH.."hump.vector"	)

require 'src.entities.Zombie'

IndividualMind = Class {

	formations = {
		unite = function(pthurst)
			return {
				friendSeparation = 5,
				wallSeparation = 5,
				alignment = 10,
				cohesion = 1,
				objective = 1,
				thurst = pthurst
			}
		end,
		ambush = function(pthurst)
			return {
				friendSeparation = 10,
				wallSeparation = 20,
				alignment = 1,
				cohesion = 1,
				objective = 1,
				thurst = pthurst
			}
		end,

	},

	init = function(self, globalmind, pawn)
		self.globalmind = globalmind
		self.pawn = pawn
		self.forward = Vector(0,0)

		self.pawn.ai = self

		-- Vectores de influencia:
		-- * Separación (gira para evitar obstáculos y vecinos locales)
		-- * Alineación (apuntar hacia donde apunta la media)
		-- * Cohesión (giro hacia la posición media)
		-- * Objetivo Hero?

		self.params = self.formations.ambush(250)
		self.influenceVecs = {
			friendSeparation = Vector(0,0),
			wallSeparation = Vector(0,0),
			alignment = Vector(0,0),
			cohesion = Vector(0,0),
			objective = Vector(0,0)
		}

		self.attack = {
			nextAttack = love.timer.getTime(),
			attackRate = 0.3,
			damageDealt = 7,
		}
	end,

	resolveAttack = function(self)
		local v2p = (self.globalmind.hero.pos - self.pawn.pos)
		if love.timer.getTime() > self.attack.nextAttack then
			self.attack.nextAttack = love.timer.getTime() + self.attack.attackRate
			if v2p:len() < 50 then
				local hitplayer = self.pawn.stage.physicworld:raycastToPlayer(self.pawn, v2p)
				if hitplayer then
					love.audio.play(Sfx.Hit_Hurt3)
					self.globalmind.hero.health = self.globalmind.hero.health - self.attack.damageDealt
					SpawnFourBloodParticle(self.globalmind.hero.pos)
					self.globalmind.hero.isHurting = self.globalmind.hero.isHurting - 50
				end
			end
		end
	end,

	controller = function(pawn)
		pawn.physicbody:setLinearVelocity(pawn.ai.forward.x * pawn.ai.params.thurst, pawn.ai.forward.y * pawn.ai.params.thurst)
	end,

	resetInfluence = function(self)
		for k,v in pairs(self.influenceVecs) do
			v.x, v.y = 0, 0
		end
	end,

	computeInfluence = function(self)
		self:resolveAttack()
		self:resetInfluence()
		self.perceived = {}
		-- perform raycast
		local physicsResult = self.pawn.stage.physicworld:raycastZombiePerception(self.pawn, self.forward, 360)
		local sumFwd = Vector(0,0)
		local numFriendsNearby = 0
		self.numwalls = 0
		for k, hit in pairs(physicsResult) do
			local ent = hit.ent
			local diff = hit.point - self.pawn.pos
			local len = diff:len()
			if ent.entitytype == "zombie" then
				if ent.ai.globalmind.teamid == self.globalmind.teamid then
					if len < 50 then
						self.influenceVecs.friendSeparation:sum_inplace( -diff / len )
					elseif len > 100 and len < 500 then
						self.influenceVecs.cohesion:sum_inplace( diff /len  )
					end
					if len < 500 then
						-- influences alignment
						assert(ent.ai, "Entity doesn't have an individual mind.")
						sumFwd = ent.ai.forward + sumFwd
						numFriendsNearby = numFriendsNearby + 1
					end
				else
					if len < 500 then
						-- influences strange zombie separation
					end
				end
			elseif ent.entitytype == "wall" and len < 40 then
				local arg = -diff * (5/len)
				self.numwalls = self.numwalls + 1
				local vec = Vector(arg.x, arg.y)
				self.influenceVecs.wallSeparation:sum_inplace( vec )
			elseif ent.entitytype == "hero" and len < 1000 then
				local arg = diff * (20/len)
				local vec = Vector(arg.x, arg.y)
				--self.influenceVecs.separation:sum_inplace( vec )
			end
		end

		local avgFwd = sumFwd
		self.influenceVecs.alignment = avgFwd
		self.forward.x, self.forward.y = 0, 0
		self.forward:sum_inplace(self.influenceVecs.friendSeparation * self.params.friendSeparation )
		self.forward:sum_inplace(self.influenceVecs.wallSeparation * self.params.wallSeparation)
		self.forward:sum_inplace(self.influenceVecs.cohesion * self.params.cohesion)
		self.forward:sum_inplace(self.influenceVecs.alignment * self.params.alignment)
		local objective = self.globalmind.hero.pos - self.pawn.pos
		objective = objective /objective:len()
		self.forward:sum_inplace(objective * self.params.objective)
		--self.accumForward:sum_inplace(self.forward)
		self.forward:trim_inplace(1)
		-- apply separation, cohesion and alignment
	end,

	debugDraw = function(self)
		local fwd = self.pawn.pos + self.forward * 20
		love.graphics.line(self.pawn.pos.x, self.pawn.pos.y, fwd.x, fwd.y)
		for k,v in pairs(self.influenceVecs) do
			fwd = self.pawn.pos + v * 20
			love.graphics.line(self.pawn.pos.x, self.pawn.pos.y, fwd.x, fwd.y)
		end
	end

}
