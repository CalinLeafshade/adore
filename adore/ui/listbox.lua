
local listbox = adore.class("adore.ui.listbox", adore.ui.control)

function listbox:initialize(...)
	self.items = {}
	self.selectedIndex = 1
	self.padding = { 4, 4}
	adore.ui.control.initialize(self,...)
	
	self:on("mousepressed", function(c,x,y,b)
			if b == "l" then
				local index = math.ceil(y / self:getItemHeight())
				if index > #self.items then
					index = -1
				end
				self.selectedIndex = index
			end
		end)
end

function listbox:getSelectedItem()
	return self.items[self.selectedIndex]
end

function listbox:getItemHeight()
	local font = self.font or adore.ui.font
	return font:getHeight() + self.padding[2] * 2
end

function listbox:draw()
	local ax, ay = self:absolutePosition()
	love.graphics.setFont(self.font or adore.ui.font)
	love.graphics.setScissor(ax,ay,self.width,self.height)
	love.graphics.setColor(self.backgroundColor)
	love.graphics.rectangle("fill", 0,0,self.width,self.height)
	love.graphics.setColor(self.color)
	love.graphics.rectangle("line", 0,0,self.width,self.height)
	love.graphics.rectangle("line", 1,1,self.width - 2,self.height - 2)
	local y = 0
	for i,v in ipairs(self.items) do
		local t = tostring(v)
		if self.selectedIndex == i then
			love.graphics.setColor(self.color)
			love.graphics.rectangle("fill", 0, y, self.width, self:getItemHeight())
			love.graphics.setColor(self.backgroundColor)
		else
			love.graphics.setColor(self.color)
		end
		love.graphics.print(t,self.padding[1], y + self.padding[2])
		y = y + self:getItemHeight()
		if y > self.height then
			break
		end
	end
	love.graphics.setScissor()
end

adore.ui.listbox = listbox