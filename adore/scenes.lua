require('adore.sceneobject')
require('adore.scenehotspot')

-- SCENE OBJECT

local scene = adore.class("adore.scene")

function scene:initialize(name)
	self.name = name
	self.masks = {}
	self.lights = {}
	self.hotspots = {}
	self.objects = {}
	self.state = {}
	self.disabledWalkableAreas = {}
	self.ambientLight = {255,255,255}
	self.showActors = true
	self.bloomSettings = {
		blurAmount = 2,
		threshold = 0.7,
		baseIntensity = 1,
		bloomIntensity = 2,
		baseSaturation = 1,
		bloomSaturation = 2
	}
end

function scene:__tostring()
	return "Scene: " .. self.name
end

function scene:afterFadeIn() end
function scene:onLoad() end
function scene:onClick() end
function scene:onPostBackgroundDraw() end

function scene:isWalkable(x,y)
	if self.masks.walkable then
		return self.masks.walkable:getPixel(x,y) > 0
	else
		return true
	end
end

function scene:getNearestNode(x,y)
	local dist = adore.math.dist
	local closest = self.pathNodes[1]
	local dd = math.huge
	for i,v in ipairs(self.pathNodes) do
		local d = dist(x,y,v.x,v.y)
		if d < dd then
			dd = d
			closest = v
		end
	end
	return closest
end

function scene:getPath(fromX, fromY, toX, toY)
	return adore.path(self, self.position.x,self.position.y,x,y)
end

function scene:repex() end

function scene:gather()
	local objs = {}
	if self.showActors then
		for i,v in adore.actors.enumerate() do
			if v:getScene() == self.name then
				table.insert(objs, v)
			end
		end
	end
	for i,v in ipairs(self.objects or {}) do
		if v.visible then
			table.insert(objs, v)
		end
	end
	for i,v in ipairs(self.walkbehinds or {}) do
		table.insert(objs, v)
	end
	return objs
end

function scene:newObject(o)
	self.objects = self.objects or {}
	o = o or {}
	o.id = o.id or #self.objects + 1
	local obj = adore.sceneObject(o)
	table.insert(self.objects, obj)
	return obj
end

function scene:newHotspot(o)
	self.hotspots = self.hotspots or {}
	o = o or {}
	o.id = o.id or #self.hotspots + 1
	local obj = adore.hotspot(o)
	table.insert(self.hotspots, obj)
	return obj
end

function scene:disableWalkableArea(id)
	self.disabledWalkableAreas[id] = true
end

function scene:enableWalkableArea(id)
	self.disabledWalkableAreas[id] = nil
end

function scene:draw()
	love.graphics.setColor(255,255,255)
	if self.images["background"] ~= nil then
		love.graphics.draw(self.images["background"],0,0)
	end
	self:onPostBackgroundDraw()
	adore.runEvent("postBackgroundDraw", self)
	if adore.debug.enabled and self.nodemap then
		love.graphics.setColor(200,100,150,128)
		self.nodemap:draw()
	end
	love.graphics.setColor(255,255,255)
	local objs = self:gather()

	table.sort(objs, function(a,b) return (a.baseline or a.position.y) < (b.baseline or b.position.y) end)
	for i,v in ipairs(objs) do
		if v.draw then
			v:draw()
			if adore.debug.enabled and v.path then
				v.path:draw()
			end
		elseif v.sprite and self.images[v.sprite] then
			love.graphics.setColor(255,255,255)
			love.graphics.draw(self.images[v.sprite], v.position.x, v.position.y, 0, 1,1,0,self.images[v.sprite]:getHeight())
		end
	end
	if adore.debug.enabled then
		local hotspotsMask = self.masks.hotspots
		if hotspotsMask then
			hotspotsMask:debugDraw()
		end
	end
end

function scene:getScalingAt(x,y)
	if self.nodemap and self.scaling then
		local minY = self.nodemap.minY
		local maxY = self.nodemap.maxY
		if minY == maxY then
			y = 1
		else
			y = (adore.math.clamp(y, minY, maxY) - minY) / (maxY - minY)
		end
		return adore.math.lerp(self.scaling[1], self.scaling[2], y)
	end
	return 1
end

function scene:generatePathNodes()
	local mask = self.masks.walkable

	self.nodemap = mask and adore.nodemap(mask)
end

function scene:cleanUpPathNodes()
	self.nodemap = nil
end

function scene:load()

	local timer = adore.debug.newTimer()

	timer:start()

	local files = love.filesystem.getDirectoryItems("game/gfx/scenes/" .. self.name)
	self.images = {}
	for i,v in ipairs(files) do
		if string.sub(v, -4) == ".png" then
			self.images[string.sub(v,0,-5)] = love.graphics.newImage("game/gfx/scenes/" .. self.name .. "/" .. v)
		end
	end

	timer:mark("sceneGraphicEnd")

	local masks = love.filesystem.getDirectoryItems("game/gfx/scenes/".. self.name .. "/masks")
	self.masks = {}
	self.maskImages = {}
	for i,v in ipairs(masks) do
		if string.sub(v, -4) == ".png" then
			self.masks[string.sub(v,0,-5)] = adore.mask("game/gfx/scenes/" .. self.name .. "/masks/" .. v)
		end
	end

	self:generateWalkBehinds()

	timer:mark("maskGraphicEnd")

	self:generatePathNodes()

	timer:stop()

	print("It took: " .. timer:delta("start", "sceneGraphicEnd") .. " seconds to load the scene graphics")
	print("It took: " .. timer:delta("sceneGraphicEnd", "maskGraphicEnd") .. " seconds to load the mask graphics")
	print("It took: " .. timer:delta("maskGraphicEnd", "stop") .. " seconds to generate the path nodes")

	self:checkRequiredSprites()
end

function scene:checkRequiredSprites()
	for i,v in ipairs(self.objects) do
		if not self.images[v.sprite] then
			print("MISSING OBJECT GRAPHIC: " .. v.sprite)
		end
	end
end

function scene:generateWalkBehinds()
	if self.masks.walkbehinds and self.walkbehinds then
		local mask = self.masks.walkbehinds
		for i,v in ipairs(self.walkbehinds) do
			local img = love.image.newImageData("game/gfx/scenes/" .. self.name .. "/background.png")
			img:mapPixel(function(x,y,r,g,b,a)
						if mask:getPixel(x,y) == i then
							return r,g,b,a
						else
							return 0,0,0,0
						end
					end)
			v.image = love.graphics.newImage(img)
			v.position = {
				y = v.baseline
			}
			v.draw = function()
				love.graphics.draw(v.image, 0,0)
			end
		end
	end
end

function scene:unload()

	-- Unload images
	self.images = nil

	-- Unload masks
	self.masks = nil

	scene:cleanUpPathNodes()

end


function scene:query(x,y)
	local tests = {}
	if not adore.util.contains(x,y,0,0,self:getWidth(), self:getHeight()) then
		return nil
	end

	if self.showActors then
		for i,v in adore.actors.enumerate() do
			if v:inCurrentRoom() and v:getClickable() then
				table.insert(tests, { obj = v, type = "actor" })
			end
		end
	end
	--TODO add objects and shit here
	table.sort(tests, function(a,b) return a.obj.position.y < b.obj.position.y end)
	for i,v in ipairs(tests) do

		if v.obj:hitTest(x,y) then
			return v.obj, v.type
		end
	end

	-- couldnt find any pixel perfect stuff, now try hotspots
	if self.masks.hotspots then
		local hotspotID  = self.masks.hotspots:getPixel(x,y)
		if hotspotID > 0 then
			return self.hotspots[hotspotID], "hotspot"
		end
	end

end

function scene:getWidth()
	local bg = self.images.background
	if bg then
		return bg:getWidth()
	else
		return adore.getGame().config.resolution[1]
	end
end

function scene:getHeight()
	local bg = self.images.background
	if bg then
		return bg:getHeight()
	else
		return adore.getGame().config.resolution[2]
	end
end


--- SCENES MODULE

local scenes = {}

local current = nil
local loaded = {}

function scenes.draw()
	if current then current:draw() end
end

function scenes.getCurrent()
	return current
end

function scenes.new(name)
	o = scene(name)
	loaded[name] = o
	return o
end

function scenes.enumerate()
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

function scenes.change(name, x, y, dir)

	local timer = adore.debug.newTimer()

	timer:start()

	-- Unload the current scene
	if current then
		adore.camera.fadeOut(1)
		print("unload")
		current:unload()
	end

	timer:mark("unloadEnd")


	-- Load the next scene
	current = loaded[name]
	current:load()
	current:onLoad()

	timer:mark("loadEnd")

	adore.bloom.settings(current.bloomSettings)

	-- Disable bloom TODO: Enable?
	if not current.bloom then
		adore.bloom.disable()
	else
		adore.bloom.enable()
	end

	if x then
		if type(x) == "table" then
			y = x.y
			x = x.x
		end
		Player:setScene(name, x,y)
		if dir then
			Player:setDirection(dir)
		end
	end
	-- step the timer
	love.timer.step()
	adore.camera.fadeIn(1)

	print("It took: " .. timer:delta("start", "unloadEnd") .. " seconds to unload the scene.")
	print("It took: " .. timer:delta("unloadEnd", "loadEnd") .. " seconds to load the next scene.")

	current:afterFadeIn()

end

function scenes.load()
	local files = love.filesystem.getDirectoryItems("game/scenes")
	table.sort(files)
	for i,v in ipairs(files) do
		love.filesystem.load("game/scenes/" .. v)()
	end
end

return scenes
