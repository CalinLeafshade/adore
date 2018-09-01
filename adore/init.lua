io.stdout:setvbuf("no")

adore = {}

local debug = require('debug')

local eventQueue = {}
local game = {}
local gfxScale = 5
local canvas = nil
local accumulator = 1/60
local frameRate = 1/60

local gameLogicCoroutine, gameLogicAlwaysCoroutine

local eventHooks = {}

function adore.getGameDT()
	return frameRate
end

function adore.event(name, priority, fn)
	if type(priority) == "function" then
		fn = priority
		priority = 100
	end
	eventHooks[name] = eventHooks[name] or {}
	table.insert(eventHooks[name], {priority = priority, fn = fn })
	table.sort(eventHooks[name], function(a,b) return a.priority < b.priority end)
end

function adore.runEvent(name, ...)
	if eventHooks[name] then
		for i,v in ipairs(eventHooks[name]) do
			local res = v.fn(...)
			if res then
				print("breaking on " .. name)
				break
			end
		end
	end
end

function adore.initGFX()
	love.window.setMode(game.config.resolution[1] * gfxScale, game.config.resolution[2] * gfxScale, {fullscreen = false, vsync = true, display = 2})
	love.window.setTitle(game.config.title)
	love.graphics.setDefaultFilter("nearest", "nearest")
	canvas = love.graphics.newCanvas(game.config.resolution[1],game.config.resolution[2])
end

function adore.update(dt)
	accumulator = accumulator - dt
	while accumulator <= 0 do
		local mx,my = love.mouse.getPosition()
		mx = math.floor(mx / gfxScale)
		my = math.floor(my / gfxScale)
		adore.mouse.x = mx
		adore.mouse.y = my
		local ok, err = coroutine.resume(gameLogicCoroutine, frameRate)
		if not ok then
			error(err .. "\n\nCoroutine stack\n\n" .. debug.traceback(gameLogicCoroutine))
		end
		ok, err = coroutine.resume(gameLogicAlwaysCoroutine, frameRate)
		if not ok then
			error(err .. "\n\nCoroutine stack\n\n" .. debug.traceback(gameLogicAlwaysCoroutine))
		end
		accumulator = accumulator + frameRate
	end
end

function adore.draw()
	if canvas then

		love.graphics.setCanvas(canvas)
		love.graphics.clear()
		
		-- Draw camera translated thingies
		adore.camera.attach()
		adore.bloom.preDraw()
		adore.scenes.draw()
		adore.camera.detach()

		-- Draw non-camera translated thingies
		adore.dialogs.draw()
		adore.bloom.draw()
		adore.overlays.draw()
		adore.ui.draw()

		adore.runEvent("postDraw")

		love.graphics.setCanvas()
		canvas:setFilter("nearest", "nearest")

		love.graphics.setColor(255,255,255)
		love.graphics.draw(canvas,0,0,0,gfxScale, gfxScale)

		-- Draw native things
		adore.runEvent("nativeDraw")
		adore.actors.drawSpeech()

	end

	-- Do some debug printing
	if adore.debug.enabled then

		local mx,my = adore.mouse.getPosition()
		local rx,ry = adore.camera.toRoom(mx,my)
		local debugTexts = {}
		table.insert(debugTexts, "Screen: " .. mx .. ", " .. my)
		table.insert(debugTexts, "Room: " .. rx .. ", " .. ry)
		local scene = adore.scenes.getCurrent()
		if scene then
			local hit = scene:query(rx,ry)
			if hit then
				table.insert(debugTexts, "Query: " .. (hit.id or "") .. " - " .. (hit.name or "UNKNOWN"))
			else
				-- lets try querying the mask directly
				if scene.masks.hotspots then
					local hsid = scene.masks.hotspots:getPixel(rx,ry)
					if hsid then
						table.insert(debugTexts, "HotspotID: " .. hsid)
					end
				end
			end
		end

		if adore.isBlocked() then
			table.insert(debugTexts, "Blocked")
		end

		adore.graphics.print(table.concat(debugTexts, "\n"), adore.debugFont, adore.graphics.colours.white,5,5)

		local itemY = game.config.resolution[2] - 20

		for k,v in pairs(Player.inventory:getItems()) do
			local item = v.item.name .. " (" .. v.count .. ")"
			adore.graphics.print(item, adore.debugFont, adore.graphics.colours.white, 5, itemY)
			itemY = itemY - 20
		end

	end

end

function adore.getGame()
	return game
end

--refactor
local doOnceKeys = {}

function adore.doOnce(key)
	local res = not doOnceKeys[key]
	doOnceKeys[key] = true
	return res
end

function adore.mousepressed(x,y,b)
	x = math.floor(x / gfxScale)
	y = math.floor(y / gfxScale)
	local c = adore.ui.controlAt(x,y)
	if c and c.clickable then
		adore.ui.mousepressed(x,y,b)
		table.insert(eventQueue, {event = "on_ui_mouse_press", args = {x,y,b,c}})
	else
		table.insert(eventQueue, {event = "on_mouse_press", args = {x,y,b}})
	end
end

function adore.mousereleased(x,y,b)
	x = math.floor(x / gfxScale)
	y = math.floor(y / gfxScale)
	local c = adore.ui.controlAt(x,y)
	if c and c.clickable then
		adore.ui.mousereleased(x,y,b)
		table.insert(eventQueue, {event = "on_ui_mouse_release", args = {x,y,b,c}})
	else
		table.insert(eventQueue, {event = "on_mouse_release", args = {x,y,b}})
	end
end

function adore.queryScreen(x,y)
	local c = adore.ui.controlAt(x,y)
	if c then
		return c, "ui"
	end
	local rx,ry = adore.camera.toRoom(x,y)
	return adore.scenes.getCurrent():query(rx,ry)
end

function adore.quit()
	love.event.push("quit")
end

function adore.keypressed(key)
	if key == "l" then
		adore.actors.lighting = not adore.actors.lighting
	elseif key == "d" then
		adore.debug.enabled = not adore.debug.enabled
	elseif key == "c" then
		adore.debug.showChangeRoomDialog()
	end

	table.insert(eventQueue, {event="on_key_press", args = { key }})
end

function adore.loadUserScripts()
	local files = love.filesystem.getDirectoryItems("game/scripts")
	for i,v in ipairs(files) do
		assert(love.filesystem.load("game/scripts/" .. v), "error in userscript")()
	end
end

function adore.loadGame()
	game = {}
	game.config = require('game')
	game.state = {}

	adore.graphics.load()
	adore.items.load()
	adore.scenes.load()
	adore.actors.load()
	adore.dialogs.load()
	adore.ui.load()

	adore.loadUserScripts()
	adore.camera.followActor(Player)

	adore.speechFont = adore.graphics.newFont(game.config.speechFont.font, game.config.speechFont.size)
	adore.debugFont = adore.graphics.newFont("adore_debug", 16)

	love.filesystem.setIdentity(game.config.title)
end

function adore.gameLogic(dt)
	adore.scenes.change(Player:getScene())
	while true do
		adore.inGameLogic = true
		for i,v in ipairs(eventQueue) do
			adore.runEvent(v.event, unpack(v.args))
		end
		adore.runEvent("repeatedly_execute", adore.getGameDT())
		local s = adore.scenes.getCurrent()
		if s then
			s:repex(dt)
		end
		adore.inGameLogic = false
		coroutine.yield()
	end
end

function adore.gameLogicAlways(dt)
	while true do
		adore.inGameLogicAlways = true
		adore.actors.update(dt)
		adore.ui.update(dt)
		adore.camera.update(dt)
		adore.overlays.update(dt)
		adore.dialogs.update(dt)
		adore.inGameLogicAlways = false
		adore.runEvent("repeatedly_execute_always", adore.getGameDT())
		eventQueue = {}
		coroutine.yield()
	end
end

function adore.run(args)

	require('adore.lib.lualinq')
	adore.class = require('adore.lib.middleclass')
	adore.vector = require('adore.lib.vector')
	adore.json = require('adore.lib.json')

	-- Load debug as the first Adore module, and check if debug mode has been enabled via args
	require("adore.debug")
	adore.debug.enabled = from(args):any(function(v) return v == "-debug" end)

	adore.mask = require("adore.mask")
	adore.persist = require("adore.persist")
	require("adore.ui")
	adore.palette = require('adore.palette')
	adore.util = require("adore.util")
	require("adore.shaders")
	require("adore.bloom")
	require("adore.overlays")
	adore.graphics = require("adore.graphics")
	adore.camera = require("adore.camera")
	adore.mouse = require("adore.mouse")
	adore.animation = require("adore.animation")
	adore.nodemap = require("adore.nodemap")
	adore.path = require("adore.path")
	adore.actor = require("adore.actor")
	adore.actors = require("adore.actors")
	adore.scenes =require("adore.scenes")
	adore.inventories = require("adore.inventories")
	require("adore.items")
	adore.math = require("adore.math")
	require("adore.dialogs")
	adore.sound = require("adore.sound")

	adore.easing = require("adore.lib.easing")
	adore.loadGame()
	adore.initGFX()
	gameLogicCoroutine = coroutine.create(adore.gameLogic)
	gameLogicAlwaysCoroutine = coroutine.create(adore.gameLogicAlways)

end

-- SCRIPT COMMANDS

function adore.wait(time)
	assert(not adore.inGameLogicAlways, "You can't wait in the persistent loop")
	while time > 0 do
		time = time - 1
		coroutine.yield()
	end
end

function adore.isBlocked()
	return adore.inGameLogic
end

function adore.reloadAssets()
	for i,v in adore.actors.enumerate() do
		v:reloadAssets()
	end
	local currentScene = adore.scenes.getCurrent()
	currentScene:load()
end
--register callbacks

local callbacks = {"update", "draw", "keypressed", "mousepressed", "keyreleased" ,"mousereleased"}
for i,v in ipairs(callbacks) do love[v] = adore[v] end
