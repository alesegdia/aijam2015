

local Class         = require (LIBRARYPATH.."hump.class"	)
local Vector        = require (LIBRARYPATH.."hump.vector"	)


local RC_nearest_PERC = function( rh, ignore )
	ignore = ignore or {}
  return function( fixture, x, y, xn, yn, fraction )
  	local userdata = fixture:getBody():getUserData()
	rh.lastent = userdata
	if rh.lastent ~= ignore then
		rh.x, rh.y, rh.xn, rh.yn = x, y, xn, yn
		return fraction
	else
		return -1
	end
  end
end

local RC_nearest = function( rh, ignore )
	ignore = ignore or {}
  return function( fixture, x, y, xn, yn, fraction )
  	local userdata = fixture:getBody():getUserData()
	rh.lastent = userdata
	if rh.lastent ~= ignore then
		rh.x, rh.y, rh.xn, rh.yn = x, y, xn, yn
		return fraction
	else
		return 1
	end
  end
end

local RC_nearest2 = function( rh )
  return function( fixture, x, y, xn, yn, fraction )
  	local userdata = fixture:getUserData()
  	if userdata.collayer ~= map_layer then return -1 end
	rh.x, rh.y, rh.xn, rh.yn = x, y, xn, yn
	return fraction
  end
end

PhysicWorld = Class {

  init = function(self, gravx, gravy, m2pix)
	self.w = love.physics.newWorld( gravx, gravy, true )
	love.physics.setMeter( m2pix )
	self.m2pix = m2pix
  end,

  -- FIX TO NOT DETECT ITSELF, SEND HERO
  raycastShotgun = function( self, origin, dir, coneAngle, numRays, handler, shooter )
  	  local anglestep = coneAngle / numRays
  	  for i=-coneAngle/2,coneAngle/2,anglestep do

  	  	  local rh = self:raycast( origin, dir, i, 1000, shooter, RC_nearest )
  	  	  if rh.lastent ~= nil then
  	  	  	  if rh.lastent.entitytype == "zombie" then
				handler(rh.lastent)
			end
		  end
	  end
  end,

  -- returns elements in area
  raycastZombiePerception = function( self, zombie, dir, numRays )
  	  numRays = 30
  	  local coneAngle = 360
  	  local anglestep = coneAngle / numRays
  	  local neighboors = {}
  	  for i=-coneAngle/2,coneAngle/2,anglestep do
  	  	  local rh = self:raycast( zombie.pos, Vector(1,0), i, 500, zombie, RC_nearest_PERC )
  	  	  if rh.lastent ~= nil and rh.lastent ~= zombie then
  	  	  	  local obj = { point = Vector(rh.x, rh.y), ent = rh.lastent }
			neighboors[rh.lastent.id] = obj
		  end
	  end
	  return neighboors
  	  -- maybe query? would suffice
  end,

  raycast = function(self, base, dir, angle, raymod, ignore, func )
  	  ignore = ignore or {}
	  angle = angle or 0
	  raymod = raymod or 2000
	  local v = base + dir:rotated(angle) * raymod
		table.insert(debugRays, {o = base, dir = v})
	  local rayhit = { x=0,y=0,xn=0,yn=0,fix=nil }
	  --print("vx: " .. angle) -- base.x)
	  --print("vy: " .. base.y)
	  if base:dist2(v) > 0 then
		self.w:rayCast(base.x, base.y, v.x,v.y,func(rayhit, ignore))
	end
	  return rayhit
  end,

  createBody_ = function( self, x, y, shape, mass, static )
	mass = mass or 10
	local obj = {}
	obj = love.physics.newBody( self.w, x, y, (static or "dynamic") )
	obj:setMass(mass)
	local fix = love.physics.newFixture( obj, shape )
	return obj
  end,

  createBody = function( self, x, y, mass, static )
  	local obj = {}
	obj = love.physics.newBody( self.w, x, y, (static or "dynamic") )
	obj:setMass(mass)
	return obj
  end,

  addRectFixture = function( self, phb, offx, offy, w, h, ang )
	local s = love.physics.newRectangleShape( offx, offy, w, h, ang )
	local f = love.physics.newFixture( phb, s )
  end,

  addPolygonFixture = function( self, phb, lst )
	local s = love.physics.newPolygonShape( unpack(lst) )
	local f = love.physics.newFixture( phb, s )
  end,

  addEdgeFixture = function( self, phb, lst )
	print(#lst)
  	for i = 1,((#lst)-1) do
	  local s = love.physics.newEdgeShape( lst[i].x, lst[i].y, lst[i+1].x, lst[i+1].y )
	  local f = love.physics.newFixture( phb, s )
	end
  end,

  createSphereBody = function( self, x, y, radius, mass, static )
	return self:createBody_( 0, 0, love.physics.newCircleShape( radius ), mass, static )
  end,

  createRectangleBody = function( self, x, y, w, h, mass, static )
  	return self:createBody_( x, y, love.physics.newRectangleShape( w, h ), mass, static )
  end,

  createPlayer = function( self, x, y )
	  local phb = love.physics.newBody( self.w, x, y, "dynamic" )
	  local s = love.physics.newCircleShape(-2,-33,10)
	  local f = love.physics.newFixture( phb, s, 0 )
	  f:setFriction(0)
	  s = love.physics.newCircleShape(-2,-13,10)
	  f = love.physics.newFixture( phb, s, 0 )
	  f:setFriction(0)
	  s = love.physics.newRectangleShape(-2,-20,20,18)
	  f = love.physics.newFixture( phb, s, 0)
	  f:setFriction(0)
	  return phb
  end,

  createZombie = function( self, x, y )
	  local phb = love.physics.newBody( self.w, x, y, "dynamic" )
	  local s = love.physics.newCircleShape(0,-10,10)
	  local f = love.physics.newFixture( phb, s, 0)
	  s = love.physics.newCircleShape(0,10,10)
	  f = love.physics.newFixture( phb, s, 0)
	  s = love.physics.newRectangleShape(0,0,20,15)
	  f = love.physics.newFixture( phb, s, 0)
	  return phb
  end,

  createBullet = function( self, x, y )
	  local phb = love.physics.newBody( self.w, x, y, "dynamic" )
	  phb:setMass(1)
	  local s = love.physics.newRectangleShape(8, 4)
	  local f = love.physics.newFixture( phb, s )
	  phb:setBullet(true)
	  f:setSensor(true)
	  return phb
  end



}


