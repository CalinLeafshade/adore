
local dialogs = {}	
	
local menu = {}
local showingMenu = false

local t = 0
local border = 20
local loaded = {}

function dialogs.start(d)
	dialogs.active = d
	dialogs.runNode(d.nodes.entry)
end

function dialogs.runNode(node)
	local fn
	if type(node) == "function" then		
		fn = node
	else
		fn = node.action
	end
	local res = fn()
	if type(res) == "boolean" and res == true then
		return dialogs.stop()
	elseif type(res) == "string" then
		return dialogs.runNode(dialogs.active.nodes[res])
	else
		return dialogs.displayMenu()
	end
end

function dialogs.stop()
	dialogs.active = nil
	showMenu = false
end

function dialogs.displayMenu()
	local d = dialogs.active
	menu = {}
	for i,v in pairs(d.nodes) do
		if type(v) == "table" and v.active then
			table.insert(menu, {id = i, node = v})
		end
	end
	showingMenu = true
end

local function getY()
	local tt = adore.easing.inOutQuad(t,0,1,1)
	local font = adore.speechFont
	local h = font:getHeight() * #menu + border
	local y = 1080 - (h * tt)
	return y
end

adore.event("on_mouse_press", -1000, function(x,y,b)
	if showingMenu then
		local font = adore.speechFont
		local boxY = getY()
		local y = y - boxY - border / 2
		local i = math.ceil(y / font:getHeight())
		if menu[i] then
			showingMenu = false
			dialogs.runNode(menu[i].node)
		end
		return true
	end
end)

function dialogs.update(dt)
	if showingMenu then
		t = math.min(t + adore.getGameDT() * 1.4, 1)
	else
		t = math.max(t - adore.getGameDT() * 1.4, 0)
	end
end

function dialogs.draw()
	if t > 0 then
		local y = getY()
		local mx, my = adore.mouse.getPosition()
		local font = adore.speechFont
		local h = font:getHeight() * #menu + border
		adore.graphics.rectangle(0,y,1920, h, true, adore.graphics.colour(0,0,0,100))
		for i,v in ipairs(menu) do
			local col = adore.graphics.colours.white
			if my > y + border / 2 and my < y + font:getHeight() + border / 2 then
				col = adore.graphics.colour(255,0,0)
			end
			adore.graphics.print(v.node.text, font, col, border, y + border / 2)
			y = y + font:getHeight()
		end
	end
end

local dialog = adore.class('adore.dialog')

function dialog:initialize(name)
	self.nodes = {}
	self.name = name
	table.insert(loaded, self)
end

function dialog:start()
	dialogs.start(self)
end

function dialogs.enumerate()
	local fn = coroutine.create(function()
			for i,v in pairs(loaded) do
				coroutine.yield(i,v)
			end
		end)
    return function ()
		_,i,v = coroutine.resume(fn) 
	    return i,v
    end
end

function dialogs.load()
	local files = love.filesystem.getDirectoryItems("game/dialogs")
	table.sort(files)
	for i,v in ipairs(files) do
		love.filesystem.load("game/dialogs/" .. v)()
	end
end

adore.dialogs = dialogs
adore.dialog = dialog
