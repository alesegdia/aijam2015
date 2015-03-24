

local Class         = require (LIBRARYPATH.."hump.class"	)

PhysicWorld = Class {

  init = function(self, gravx, gravy, m2pix)
	self.w = love.physics.newWorld( gravx, gravy, true )
	love.physics.setMeter( m2pix )
	self.m2pix = m2pix
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
	  s = love.physics.newCircleShape(-2,-13,10)
	  f = love.physics.newFixture( phb, s, 0 )
	  s = love.physics.newRectangleShape(-2,-20,20,18)
	  f = love.physics.newFixture( phb, s, 0)
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


