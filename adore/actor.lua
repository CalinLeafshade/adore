local class = require("adore.lib.middleclass")
local actor = class("adore.actor")
local persist = require("adore.persist")
local inventories = require("adore.inventories")
local vector = require("adore.lib.vector")
local colour = require("adore.graphics").colour
local util = require("adore.util")
local camera = require("adore.camera")
local mouse = require("adore.mouse")
actor:include(persist.mixin.persistable)

function actor:initialize(name)
	self.name = name
	self.position = vector(200,400)
	self.color = {255,255,255}
	self.walkDelay = 0.1
	self.walkSpeed = 4
	self.direction = "right"
	self.clickable = true
	self.walkSet = {}
	self.pixelPerfect = true
	self.speechColor = colour(200,200,200)
	self.speechTimer = 0
	self.speaking = false

	-- All actors have an inventory
	self.inventory = inventories.new("actor_" .. name)

	-- All actors are persisted
	persist.register("actor_" .. self.name, self)

end

function actor:getClickable()
	return self.clickable
end

function actor:setClickable(click)
	if type(click) ~= "boolean" then
		error("Clickable is a boolean")
	end
	self.clickable = click
end

function actor:setScene(scene, x,y)
	self.scene = scene

	if x then
		if type(x) == "table" then
			y = x.y
			x = x.x
		end
		if not y then
			error("No y coord passed to setScene")
		end
		self.position = vector(x,y)
	end

end

function actor:getScene()
	return self.scene
end

function actor:say(what)
	if not what then
		return self
	end
	self:stop()
	self.speechTimer = 0
	self.speechNumber = nil
	if string.starts(what, "&") then
		self.speechNumber = tonumber(string.match(what, "&(%d+)"))
		self.speechSource = love.audio.newSource("/game/speech/" .. self.name:lower() .. self.speechNumber .. ".mp3")
		self.speechSource:play()
		what = string.match(what, "&%d+%s?(.+)")
	end
	self.sayingText = self.name .. ": " .. what
	self.speaking = true
	while self.speaking do
		if love.mouse.isDown(1) and self.speechTimer * 1000 > 500 then
			self.speaking = false
		else
			coroutine.yield()
		end
	end
	return self
end

function actor:drawSpeech()

	if not self.speaking then return end

	local nativeW = love.graphics.getWidth()
	local nativeH = love.graphics.getHeight()

	local targetW = nativeW * 0.8
	local targetW = nativeW * 0.8
	local font = adore.speechFont
	local w,lines = font:getWrap(self.sayingText, targetW)
	local y = nativeH - 50 - font:getHeight() * #lines
	local x = nativeW * 0.1
	w = targetW
	local shadowColour = adore.graphics.colour(10, 10, 10)

	adore.graphics.printf(self.sayingText, font, shadowColour, x - 1, y, w, "center")
	adore.graphics.printf(self.sayingText, font, shadowColour, x + 1, y, w, "center")
	adore.graphics.printf(self.sayingText, font, shadowColour, x, y - 1, w, "center")
	adore.graphics.printf(self.sayingText, font, shadowColour, x, y + 1, w, "center")

	adore.graphics.printf(self.sayingText, font, self.speechColor, x, y, w, "center")
end

function actor:getHeight()
	local ani = self:getAnimation()
	if ani then
		return ani:getHeight()
	end
	return 0
end

function actor:getWidth()
	local ani = self:getAnimation()
	if ani then
		return ani:getWidth()
	end
	return 0
end

local function drawActor(self, x,y, scale)
  self.walkSet[self.direction]:draw(x,y,scale,scale)
  if self.speaking and self.speechNumber and self.speechSource then
    local data = self.lipsyncData[self.speechNumber]
    if not data then return end
    local t = self.speechSource:tell("seconds")
    local item = nil
    for i,v in ipairs(data) do
      if t < v[1] then
        break
      end
      item = v[2]
    end
    if not item then
      return
    end
    local lip = self.lips and self.lips[item] and self.lips[item][self.direction]
    if lip then
      love.graphics.draw(lip, x + self.lips.offset[1] * scale, y + self.lips.offset[2] * scale, 0, scale,scale,lip:getWidth() / 2, lip:getHeight() / 2)
    end
  end
end

function actor:getCurrentScale()
	local scale = 1

	if not self.ignoreScaling then
		local x,y = self.position:unpack()
		if self.pixelPerfect then
			x,y = math.floor(x + 0.5), math.floor(y + 0.5)
		end
		local currentScene = adore.scenes.getCurrent()
		scale = currentScene:getScalingAt(x,y)
	elseif self.manualScale then
		scale = self.manualScale
	end

	return scale

end

function actor:setDirection(dir)
	if not util.validDir(dir) then
		error("Invalid direction to face: " .. tostring(dir))
	end
	self.direction = dir
	local ani = self:getAnimation()
	if not ani then
		error("No dir for character" .. self.name .. dir)
	end
	ani:reset()
end

function actor:faceDirection(dir)
	local curr = self.direction
	if (curr == "left" and dir == "right") or (curr == "right" and dir == "left") then
		self:setDirection("down")
		adore.wait(5)
		self:setDirection(dir)
	elseif (curr == "up" and dir == "down") or (curr == "down" and dir == "up") then
		self:setDirection("left")
		adore.wait(5)
		self:setDirection(dir)
	else
		self:setDirection(dir)
	end
	return self
end

function actor:face(x,y)
	if type(x) == "string" then
		return self:faceDirection(x)
	else
		local dir = util.directionFromVector(adore.vector(x,y) - self.position)
		return self:faceDirection(dir)
	end
end

function actor:faceMouse()
	local mx,my = mouse.getPosition()
	local rx,ry = camera.toRoom(mx,my)
	self:face(rx,ry)
end

function actor:draw()
	love.graphics.setColor(self.color)
	if self.walkSet[self.direction] then
		local x,y = self.position:unpack()
		if self.pixelPerfect then
			x,y = math.floor(x + 0.5), math.floor(y + 0.5)
		end
		local currentScene = adore.scenes.getCurrent()
		local scale = self:getCurrentScale()
		if adore.actors.lighting then

			love.graphics.setColor(unpack(currentScene.ambientLight))
			drawActor(self, x, y, scale)
			love.graphics.setBlendMode("add")
			love.graphics.setShader(adore.shaders.lighting)
			love.graphics.setColor(255,255,255)
			for i,v in ipairs(currentScene.lights or {}) do
				local mx,my = adore.mouse.getPosition()
				--adore.shaders.lighting:send("Light", {v.position[1], v.position[2] - v.position[3], adore.math.clamp((self.position.y - v.position[2]) / 2, -10, 10)})
				adore.shaders.lighting:send("Light", {v.position[1], v.position[2], v.position[3]})
				adore.shaders.lighting:send("PlayerPos", {x, y, 0})
				--adore.shaders.lighting:send("PlayerSize", {self:getWidth(), self:getHeight()})
				adore.shaders.lighting:send("NormalMap", self.walkSet[self.direction].normal)
				adore.shaders.lighting:send("LightRadius", v.radius)
				adore.shaders.lighting:send("LightColor", v.color)
				adore.shaders.lighting:send("LightPower", v.power * 0.6)
				adore.shaders.lighting:send("CameraPos", {adore.camera.topLeft()})

				drawActor(self, x, y, scale)
			end
			love.graphics.setBlendMode("alpha")
			love.graphics.setShader()
		else
			local currentScene = adore.scenes.getCurrent()
			love.graphics.setColor(unpack(currentScene.ambientLight))
			drawActor(self, x, y, scale)
			love.graphics.setColor(255,255,255)
		end
	end
	if adore.debug.enabled then
		love.graphics.setColor(0,255,0)
		love.graphics.circle("fill", self.position.x,self.position.y, 3)
	end
end

function actor:stop()
	self.walking = false
	self.dest = nil
	local ani = self.walkSet[self.direction]
	if ani then
		ani:setFrame(1)
	end
end

function actor:walk(x,y, block)
	local currentScene = adore.scenes.getCurrent()
	if self.scene ~= currentScene.name then
		return self
	end
	self.dest = nil
	self.path = adore.path(currentScene, self.position.x,self.position.y,x,y)
	if self.path.unreachable then
		return self
	end
	self.walking = true
	self.walkTimer = 0
	if block then
		while self.walking do adore.wait(1) end
	end
	return self
end

-- This is a "continuous" walk method
--function actor:updateWalk(dt)
--	if not self.walking then return end
--	self.walkTimer = self.walkTimer - dt
--	if self.walkTimer <= 0 then
--		self.walkTimer = self.walkTimer + self.walkDelay
--		self.walkSet[self.direction]:nextWalkingFrame()
--	end

--	local walkPower = self.walkSpeed * dt

--	if self.direction == "up" or self.direction == "down" then
--		walkPower = walkPower * 0.7
--	end

--	while (walkPower > 0) do
--		if not self.dest then
--			local n = self.path:next()
--			if n then
--				self.dest = adore.vector(n.x,n.y)
--			end
--		end
--		if not self.dest then
--			return self:stop()
--		end

--		local dirVector = self.dest - self.position
--		local l = dirVector:len()

--		local moveVector = dirVector:normalized() * math.min(l, walkPower)
--		self.direction = util.directionFromVector(moveVector) or self.direction
--		self.position = self.position + moveVector
--		if l < walkPower then
--			self.dest = nil
--		end
--		walkPower = math.max(0, walkPower - l)
--	end
--end

-- This is a "stepped" walk method.
function actor:updateWalk(dt)
	if not self.walking then return end
	self.walkTimer = self.walkTimer - dt

	if self.walkTimer <= 0 then
		self.walkTimer = self.walkTimer + self.walkDelay
		self.walkSet[self.direction]:nextWalkingFrame()

		local walkPower = self.walkSpeed-- * dt

		if self.direction == "up" or self.direction == "down" then
			walkPower = walkPower * 0.7
		end

		while (walkPower > 0) do
			if not self.dest then
				local n = self.path:next()
				if n then
					self.dest = adore.vector(n.x,n.y)
				end
			end
			if not self.dest then
				return self:stop()
			end

			local dirVector = self.dest - self.position
			local l = dirVector:len()

			local moveVector = dirVector:normalized() * math.min(l, walkPower)
			self.direction = util.directionFromVector(moveVector) or self.direction
			self.position = self.position + moveVector
			if l < walkPower then
				self.dest = nil
			end
			walkPower = math.max(0, walkPower - l)
		end

	end
end

function actor:getPosition()
	return self.position:unpack()
end

function actor:top()
	local ani = self:getAnimation()
	if ani then
		return self.position.y - ani:getHeight() * self:getCurrentScale()
	else
		return self.position.y
	end
end

function actor:left()
	local ani = self:getAnimation()
	if ani then
		return self.position.x - ani:getWidth() * self:getCurrentScale() / 2
	else
		return self.position.x
	end
end

function actor:getWidth()
	local ani = self:getAnimation()
	if ani then
		return self:getAnimation():getWidth()
	else
		return 0
	end
end

function actor:getHeight()
	local ani = self:getAnimation()
	if ani then
		return self:getAnimation():getHeight()
	else
		return 0
	end
end

function actor:topLeft()
	return self:left(), self:top()
end

function actor:bbox()
	return self:left(), self:top(), self:getWidth() * self:getCurrentScale(), self:getHeight() * self:getCurrentScale()
end

function actor:hitTest(x,y)
	if not util.contains(x,y, self:bbox()) then
		return false
	end
	local ani = self:getAnimation()
	if ani then
		local xx,yy = self:topLeft()
		local lx, ly = (x - xx) / self:getCurrentScale(), (y - yy) /  self:getCurrentScale()
		return ani:hitTest(lx,ly )
	end
end

function actor:getAnimation()
	return self.walkSet[self.direction]
end

function actor:inCurrentRoom()
	local currentScene = adore.scenes.getCurrent()

	if currentScene then
		return (currentScene.name == self.scene)
	else
		return false
	end

end

function actor:reloadAssets()
	for i,v in pairs(self.walkSet or {}) do
		v:load()
	end
end

function actor:updateSpeech(dt)
	if not self.speaking then return end
	local game = adore.getGame()
	self.speechTimer = self.speechTimer + dt
	if self.speechTimer * 1000 > math.max(game.config.minimumSpeechTime, game.config.speechTimePerChar * self.sayingText:len()) then
		self.speaking = false
	end
end

function actor:update(dt)
	self:updateWalk(dt)
	self:updateSpeech(dt)
end

-- Persistence
function actor:getPersistenceKeys()
	return { { "position", nil, function(v) return adore.vector(v.x,v.y) end } }
end

function actor:prepareForReload()
	-- Stop speaking
	self.speaking = false

	-- Stop walking
	self:stop()
end

return actor
