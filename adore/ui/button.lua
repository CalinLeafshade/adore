
local button = adore.class("adore.ui.button", adore.ui.control)

function button:initialize(...)
	self.state = "up"
	self.hoveredColor = {130,130,130}
	adore.ui.control.initialize(self,...)
	
	self:on('enter', function(b)
			b.state = "hovered"
		end)
	
	self:on('leave', function(b)
			b.state = "up"
		end)
	
	self:on('mousepressed', function(c,x,y,b)
			c.state = "pushed"
		end)
	
	self:on('mousereleased', function(c,x,y,b)
			c.state = "hovered"
		end)

end

function button:update()
	if self.state == "pushed" and not love.mouse.isDown("l") then
		--self.state = "up"
	end
end

function button:draw()
	if self.state == "up" then
		love.graphics.setColor(self.backgroundColor)
	elseif self.state == "hovered" then
		love.graphics.setColor(self.hoveredColor)
	elseif self.state == "pushed" then
		love.graphics.setColor(self.hoveredColor)
	end
	
	love.graphics.roundrect("fill", 0,0,self.width,self.height)
	love.graphics.setColor(255,255,255)
	love.graphics.roundrect("line", 0,0,self.width, self.height)
	local font = self.font or adore.ui.font
	love.graphics.setFont(font)
	local y = self.height / 2 - font:getHeight() / 2
	if self.state == "pushed" then
		y = y + 1
	end
	love.graphics.setColor(self.color)
	love.graphics.printf(self.text, 0, math.floor(y), self.width, "center")
end

adore.ui.button = button