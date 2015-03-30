--
--  DeadScreen
--

local Gamestate     = require (LIBRARYPATH.."hump.gamestate")
local gui       = require( LIBRARYPATH.."Quickie"           )
local camera = require (LIBRARYPATH.."hump.camera")
timer = require (LIBRARYPATH.."hump.timer")
local Vector        = require (LIBRARYPATH.."hump.vector"	)
local tween         = timer.tween
local gui = require (LIBRARYPATH.."Quickie")

DeadScreen = Gamestate.new()

local center = {
        x = love.graphics.getWidth()/2,
        y = love.graphics.getHeight()/2,
    }

local bigFont   =   love.graphics.newFont(90)
local smallFont =   love.graphics.newFont(32)
local miniFont =   love.graphics.newFont(16)
local keyframe = 0
local rects = {}
local canContinue = false
local alfa = { value=0 }
function DeadScreen:enter()
	canContinue = false
	alfa.value = 0
	timer.tween(5, alfa, {value = 255}, 'quad', function() canContinue = true end)
end

function checkMouseInRect(x,y,w,h)
	local mx, my = love.mouse.getPosition()
	return mx > x and mx < x + w and my > y and my < y + h
end


function DeadScreen:update(dt)
	timer.update(dt)
end

local showClickText = true
local nextClickText = 0
local clickTextRate = 0.2
function DeadScreen:draw()
  love.graphics.setFont(bigFont)
  love.graphics.setColor(255,0,0,alfa.value)
	love.graphics.print("YOU DIED", 300, 300)
	if canContinue then
		if love.timer.getTime() > nextClickText then
			showClickText = not showClickText
			nextClickText = love.timer.getTime() + clickTextRate
		end
			love.graphics.setFont(miniFont)
		love.graphics.print("... but well, at least you killed "..tostring(hero.kills).." of those bastards.", 400, 400)
		if showClickText then
			love.graphics.setFont(smallFont)
			love.graphics.print("Click to replay", 400, 500)
		end
		if love.mouse.isDown("l") then
			Gamestate.switch(Game)
		end
	end
end

function DeadScreen:keypressed(key, code)
    gui.keyboard.pressed(key, code)
end
