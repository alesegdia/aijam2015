--
--  Menu
--

local Gamestate     = require (LIBRARYPATH.."hump.gamestate")
local gui       = require( LIBRARYPATH.."Quickie"           )
local camera = require (LIBRARYPATH.."hump.camera")
timer = require (LIBRARYPATH.."hump.timer")
local Vector        = require (LIBRARYPATH.."hump.vector"	)
local tween         = timer.tween
local gui = require (LIBRARYPATH.."Quickie")

Menu = Gamestate.new()

local center = {
        x = love.graphics.getWidth()/2,
        y = love.graphics.getHeight()/2,
    }

local keyframe = 0
local rects = {}
function Menu:enter()
	love.graphics.setColor(255,255,255,255)
	table.insert(rects,{r ={570,570,200,30}, callback = function()Gamestate.switch(Game)end})
	table.insert(rects,{r ={240,570,200,30}, callback = function()keyframe=5 end})
	timer.add(1, function()
		keyframe = 1
	end)
end

function checkMouseInRect(x,y,w,h)
	local mx, my = love.mouse.getPosition()
	return mx > x and mx < x + w and my > y and my < y + h
end


function Menu:update(dt)
	timer.update(dt)
end

function Menu:draw()
	if keyframe == 0 then
		love.graphics.draw(ImageJPG.title, 0, 0)
	elseif keyframe == 1 then
		love.graphics.draw(ImageJPG.main, 0, 0)
	elseif keyframe == 5 then
		love.graphics.draw(ImageJPG.controls4, 0, 0)
	end
    --gui.core.draw()
    if love.mouse.isDown("l") and (keyframe == 1) then
    for k,v in pairs(rects) do
		love.graphics.rectangle("line", v.r[1], v.r[2], v.r[3], v.r[4])
		if checkMouseInRect(v.r[1], v.r[2], v.r[3], v.r[4]) then
			v.callback()
		end
	end
	end

	if love.mouse.isDown("r") and (keyframe == 5) then
		keyframe = 1
	end

end

function Menu:keypressed(key, code)
    gui.keyboard.pressed(key, code)
end
