
local animation = adore.class("adore.animation")

function animation:initialize(name, file, normalFile, cols, rows,frameCount, speed, flipped, frameDelays)

	self.cols = cols
	self.rows = rows
	self.name = name
	self.frameDelays = frameDelays
	self.flipped = flipped
	self.frameCount = frameCount
	self.animationSpeed = speed
	self.file = file
	self.normalFile = normalFile
	self.currentFrame = 1

	self:load()

end

function animation:load()
	self.texture = love.graphics.newImage("game/gfx/animations/" .. self.file)

	if self.normalFile then
		self.normal = love.graphics.newImage("game/gfx/animations/" .. self.normalFile)
	end

	if self.texture then
		self.frameWidth = self.texture:getWidth() / self.cols
		self.frameHeight = self.texture:getHeight() / self.rows
		self:makeQuads()
	end
end

function animation:reset()
	self.currentFrame = 1
end

function animation:nextWalkingFrame()
	self:setFrame(self:getFrame() + 1)
	if self.currentFrame == 1 and self.frameCount > 1 then
		self.currentFrame = 2
	end
end

function animation:nextFrame()
	self:setFrame(self:getFrame() + 1)
end

function animation:setFrame(frame)

	if frame > self.frameCount then
		frame = 1
	end

	self.currentFrame = frame
end

function animation:getFrame()
	return self.currentFrame
end

function animation:getHeight()
	return self.frameHeight
end

function animation:getWidth()
	return self.frameWidth
end

function animation:makeQuads()
	self.quads = {}
	local w = self.frameWidth
	local h = self.frameHeight
	for y=0, self.rows - 1 do
		for x=0, self.cols - 1 do
			if #self.quads < self.frameCount then
				local q = love.graphics.newQuad(x * w, y * h, w,h, self.texture:getWidth(), self.texture:getHeight())
				table.insert(self.quads, q)
			end
		end
	end
end

function animation:hitTest(x, y)
	x = x + ((self.currentFrame - 1) * self.frameWidth)
	local row = math.ceil(self.currentFrame / self.cols) - 1
	y = y + row * self.frameHeight
	if x < 0 or x >= self.texture:getWidth() or y < 0 or y >= self.texture:getHeight() then
		return false
	end
	local r,g,b,a = self.texture:getData():getPixel(x,y)
	return a > 0.2
end

function animation:draw(x,y,sx,sy)
	local frameIndex = self.currentFrame
	sx = sx or 1
	sy = sy or 1
	love.graphics.draw(self.texture, self.quads[frameIndex], x, y,0,sx * (self.flipped and -1 or 1),sy,math.floor(self.frameWidth / 2), self.frameHeight)
end

return animation
