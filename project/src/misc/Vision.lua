
local Vector        = require (LIBRARYPATH.."hump.vector"	)
local Vision = {}


Vision = {
	tris = {},
	init = function(self, stage, originEntity, debug)
		self.stage = stage
		self.originEntity = originEntity
		self.debug = debug
	end,
	computeVision = function(self)
		local vision = {}
		for i=1,360,5 do
			local obj = self:Raycast(Vector(0,1), math.rad(i))
			table.insert(vision, obj)
		end
		debug = debug or false
		if #vision > 0 then
			local poly = {}
			--print("==========")
			for k,v in pairs(vision) do
			if v.x ~= v.y and v.y ~= 0 then
				table.insert(poly,v.x)
				table.insert(poly,v.y)
				--print(v.x)
				--print(v.y)
				--print("")
			end
			if debug then love.graphics.line(self.originEntity.pos.x, self.originEntity.pos.y, v.x, v.y) end
			end
			if #poly >= 3*2 then
			self.tris = love.math.triangulate(unpack(poly))
			end
		end
	end,

	RC_visionray = function( rh )
		return function( fixture, x, y, xn, yn, fraction )
			local userdata = fixture:getBody():getUserData()
			if userdata.entitytype ~= "wall" then
				return -1
			end
			rh.x, rh.y, rh.xn, rh.yn = x, y, xn, yn
			return fraction
		end
	end,

	tmpvec = Vector(0,-30),

	Raycast = function( self, dir, angle )
		angle = angle or 0
		local v = dir:rotated(angle)
		local base = self.originEntity.pos + self.tmpvec
		local rayhit = { x=0,y=0,xn=0,yn=0,fix=nil }
		--print("vx: " .. angle) -- base.x)
		--print("vy: " .. base.y)
		self.stage.physicworld.w:rayCast(base.x, base.y, base.x+v.x*2000,base.y+v.y*2000,self.RC_visionray(rayhit))
		return rayhit
	end,

	draw = function(self)
		love.graphics.setColor(0,0,0,255)
		love.graphics.rectangle("fill", self.originEntity.pos.x-512, self.originEntity.pos.y-400, 1200, 1200)
		love.graphics.setColor(255,255,255,255)
		for k,v in pairs(self.tris) do
			love.graphics.polygon("fill",unpack(v))
		end
		self.tris = {}
	end,

	visionShader = love.graphics.newShader( [[
		vec4 effect( vec4 color, Image texture, vec2 texcoords, vec2 screencoords )
		{
			vec4 c = Texel(texture, texcoords);
			if( c == vec4(1,1,1,1) ) return vec4(0,0,0,0);
			//else return vec4(0.247, 0.247, 0.455, 1);
			else return vec4(0,0,0,1);
		}

	]])

}


return Vision
