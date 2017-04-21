
local slider = adore.class("adore.ui.slider", adore.ui.control)

local handleWidth = 12

function slider:initialize(...)
	self.min = 0
	self.max = 100
	self.value = 50
	self.moving = false
	adore.ui.control.initialize(self,...)
end

function slider:mousepressed(x,y,b)
	if b ~= "l" then
		return 
	end
	local ax,ay = self:absolutePosition()
	local pos = self.value / (self.max - self.min) * self.width
	local rx,ry,rw,rh = pos - (handleWidth / 2), 0 ,handleWidth, self.height
	if contains(rx,ry,rw,rh,x,y) then
		self.moving = true
	end
end

function slider:update()
	self.value = adore.math.clamp(self.value, self.min, self.max)
	if self.moving then
		if not love.mouse.isDown("l") then
			self.moving = false
		else
			local ax,ay = self:absolutePosition()
			local pos = self.value / (self.max - self.min) * self.width
			local mx, my = love.mouse.getPosition()
			local p = (mx - ax) / self.width
			self.value = adore.math.clamp(adore.math.lerp(self.min, self.max, p), self.min, self.max)
		end
	end
end

function slider:draw()
	love.graphics.setColor(0,0,0,100)
	love.graphics.rectangle("fill", 0, self.height / 2 - (handleWidth / 3),self.width, handleWidth / 3)
	local pos = self.value / (self.max - self.min) * self.width
	love.graphics.setColor(255,255,255)
	love.graphics.draw(handle, pos - (handleWidth / 2), self.height / 2 - handle:getHeight() / 2)
end

adore.ui.slider = slider