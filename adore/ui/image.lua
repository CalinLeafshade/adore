local image = adore.class("adore.ui.image", adore.ui.control)

function image:initialize(...)
	adore.ui.control.initialize(self,...)
	self:loadImage()
end

function image:loadImage()
	if type(self.image) == "string" then
		self.image = love.graphics.newImage(self.image)
	end
end

function image:draw()
	-- incase the image changes to a new string
	self:loadImage()
	love.graphics.setColor(255,255,255)
	love.graphics.draw(self.image, 0, 0)
end

adore.ui.image = image