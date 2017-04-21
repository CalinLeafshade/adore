
local ninepatch = adore.class('adore.ui.ninepatch')

function ninepatch:initialize(image, quadSize)
	if type(image) == "string" then
		image = love.graphics.newImage(image)
	end
	self.image = image
	self.quadSize = quadSize
	local sw,sh = self.image:getWidth(), self.image:getHeight()
	self.quads = {
		topLeft = love.graphics.newQuad(0, 0, quadSize, quadSize, sw, sh ),
		top = love.graphics.newQuad(quadSize, 0, quadSize, quadSize, sw, sh ),
		topRight = love.graphics.newQuad(quadSize * 2, 0, quadSize, quadSize, sw, sh ),
		left = love.graphics.newQuad(0, quadSize, quadSize, quadSize, sw, sh ),
		centre = love.graphics.newQuad(quadSize, quadSize, quadSize, quadSize, sw, sh ),
		right = love.graphics.newQuad(quadSize * 2, quadSize, quadSize, quadSize, sw, sh ),
		bottomLeft = love.graphics.newQuad(0, quadSize * 2, quadSize, quadSize, sw, sh ),
		bottom = love.graphics.newQuad(quadSize, quadSize * 2, quadSize, quadSize, sw, sh ),
		bottomRight = love.graphics.newQuad(quadSize * 2, quadSize * 2, quadSize, quadSize, sw, sh )
	}
	self.spritebatch = love.graphics.newSpriteBatch(image, 1000)
	
end

function ninepatch:draw(x,y,w,h)
	local a = 0
	if not self.last or (self.last.w ~= w or self.last.h ~= h) then

		self.last = {w = w, h = h}
	
		self.spritebatch:clear()
		self.spritebatch:bind()
		
		for i=0,math.ceil(w / self.quadSize) - 2 do
			for j=0, math.ceil(h/self.quadSize) - 2 do
				a = a + 1
				self.spritebatch:add(self.quads.centre, i * self.quadSize, j * self.quadSize)
			end
		end
	
		self.spritebatch:add(self.quads.topLeft, x, y)
		a = a + 1
		for i=0,math.ceil(w / self.quadSize) - 3 do
			a = a + 1
			a = a + 1
			self.spritebatch:add(self.quads.top, x + self.quadSize * (i + 1), y)
			self.spritebatch:add(self.quads.bottom, x + self.quadSize * (i + 1), h - self.quadSize)
		end
		a = a + 1
		self.spritebatch:add(self.quads.topRight, w - self.quadSize, y)
		
		for i=0, math.ceil(h / self.quadSize) - 3 do
			a = a + 1
			self.spritebatch:add(self.quads.left, x, y + self.quadSize * (i + 1))
			a = a + 1
			self.spritebatch:add(self.quads.right, w - self.quadSize, y + self.quadSize * (i + 1))
		end
		a = a + 1
		self.spritebatch:add( self.quads.bottomLeft, x,h - self.quadSize)
		self.spritebatch:add(self.quads.bottomRight, w - self.quadSize,h - self.quadSize)
		a = a + 1
		self.spritebatch:unbind()
		print(a)
	end

	love.graphics.draw(self.spritebatch, x,y)
end

adore.ui.ninepatch = ninepatch
