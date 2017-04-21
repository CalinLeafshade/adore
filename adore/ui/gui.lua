
local gui = adore.class("adore.ui.gui", adore.ui.control)

function gui:initialize(...)
	adore.ui.control.initialize(self,nil,...)
end

function gui:draw()
	love.graphics.setColor(self.backgroundColor)
	love.graphics.rectangle("fill", 0,0,self.width,self.height)
	adore.ui.control.draw(self)
end

function gui:centre()
	self.x = adore.graphics.getWidth() / 2 - self.width / 2
	self.y = adore.graphics.getHeight() / 2 - self.height / 2
end

adore.ui.gui = gui