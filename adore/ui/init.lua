
local ui = {}

adore.ui = ui

require('adore.ui.control')
require('adore.ui.ninepatch')
require('adore.ui.gui')
require('adore.ui.label')
require('adore.ui.slider')
require('adore.ui.button')
require('adore.ui.image')
require('adore.ui.listbox')

local lastControlOver
local focus

ui.font = love.graphics.newFont(24)
ui.base = ui.control()
ui.events = {}

function ui.queueUIEvent(control, event, ...)
	table.insert(ui.events, { control = control, event = event, args = {...} })
end

function ui.update(dt)
	ui.base:update(dt)
	local c = ui.base:getAtXY(love.mouse.getPosition())
	if c then
		if lastControlOver and lastControlOver ~= c then
			lastControlOver:trigger("leave")
			c:trigger("enter")
		elseif not lastControlOver then
			c:trigger("enter")
		end
	else
		--no control under mouse
		if lastControlOver then
			--control undermouse last loop
			lastControlOver:trigger("leave")	
		end
	end
	lastControlOver = c
	for i,v in ipairs(ui.events) do
		v.control:trigger(v.event, unpack(v.args or {}))
	end
	ui.events = {}
end

function ui.controlAt(x,y)
	local c = ui.base:getAtXY(x,y)
	if c ~= ui.base then
		return c
	end
end

function ui.mousepressed(x,y,b)
	local c = ui.base:getAtXY(adore.mouse.getPosition())
	if c ~= base then
		local ax,ay = c:absolutePosition()
		ui.queueUIEvent(c, 'mousepressed', x - ax, y - ay, b)
	end
	focus = c
	return c ~= ui.base
end

function ui.mousereleased(x,y,b)
	local c = ui.base:getAtXY(adore.mouse.getPosition())
	if c and c == focus then
		ui.queueUIEvent(c, 'click', b)
	end
	ui.queueUIEvent(c, 'mousereleased', b)
	return c ~= ui.base
end

function ui.keypressed(key)
	if focus then
		focus:trigger('keypressed', key)
		return true
	end
	return false
end

function ui.load() 
	local f = love.filesystem.getDirectoryItems("game/ui")
	for i,v in ipairs(f) do
		love.filesystem.load("game/ui/" .. v)()
	end
end

function ui.draw()
	ui.base:draw()
end

adore.ui = ui


	
	