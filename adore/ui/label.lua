

local label = adore.class("adore.ui.label", adore.ui.control)

function label:initialize(...)
	self.text = ""
	self.alignment = "left"
	adore.ui.control.initialize(self,...)
end

function label:calculateHeight()
	local font = self.font or adore.ui.font
	local w, lines = font:getWrap(self.text, self.width)
	return font:getHeight() * lines
end

function label:draw()
	if self.text and type(self.text) == "string" then
		love.graphics.setFont(self.font or adore.ui.font)
		love.graphics.setColor(self.color)
		love.graphics.printf(self.text,0,0, self.width,self.alignment)
	end
end

adore.ui.label = label