
local control = adore.class("adore.ui.control")

function control:initialize(parent, opts)
	self.parent = parent or adore.ui.base
	self.controls = {}
	self.id = tostring({})
	self.x = 0
	self.y = 0
	self.z = 0
	self.width = 100
	self.height = 100
	self.clickable = true
	self.color = {255,255,255}
	self.backgroundColor = {100,100,100}
	self.events = {}
	self.visible = true
	if self.parent then
		self.parent:addControl(self)
	end
	for i,v in pairs(opts or {}) do
		self[i] = v
	end
end

function control:hide()
	self.visible = false
end

function control:mousepressed()
end

function control:absolutePosition()
	local x,y = self.x,self.y
	local xx,yy = 0,0
	if self.parent then
		xx,yy = self.parent:absolutePosition()
	end
	return x + xx, y + yy
end

function control:addControl(c)
	table.insert(self.controls,c)
	table.sort(self.controls, function(a,b)
			if a.z > b.z then
				return false
			elseif b.z > a.z then
				return true
			else
				return a.id > b.id
			end
		end)
end

function control:removeControl(c)
	for i,v in ipairs(self.controls) do
		if v == c then
			table.remove(self.controls, i)
		end
	end
end

function control:destroy()
	self.parent:removeControl(self)
end

function control:draw()
	
	if adore.debug.enabled and self ~= adore.ui.base then
		love.graphics.rectangle("line", 0,0,self.width, self.height)
	end
	for i,v in ipairs(self.controls) do
		if v.visible then
			love.graphics.push()
			love.graphics.translate(v.x,v.y)
			v:draw()
			love.graphics.pop()
		end
	end
	
end

function control:update(dt)
	for i,v in ipairs(self.controls) do
		v:update(dt)
	end
end

function control:on(event, fn)
	self.events[event] = self.events[event] or {}
	table.insert(self.events[event], fn)
end

function control:trigger(event, ...)
	if self[event] then
		self[event](self, ...)
	end
	for i,v in ipairs(self.events[event] or {}) do
		v(self, ...)
	end
end

function control:getAtXY(x,y)
	for i,v in ipairs(self.controls) do
		if v.visible and v:contains(x,y) then
			return v:getAtXY(x - v.x, y - v.y)
		end
	end
	return self
end

function control:contains(x,y)
	return x >= self.x and x < self.x + self.width and y >= self.y and y < self.y + self.height
end

adore.ui.control = control

