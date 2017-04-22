local mask = adore.class('adore.mask')

function mask:initialize(img)
	if type(img) == "string" then
		img = love.image.newImageData(img)
	end
	local data = {}
	img:mapPixel(function(x,y,r,g,b,a)
			if a > 0 then
				data[x] = data[x] or {}
				data[x][y] = adore.palette.find(r,g,b)
			end
			return r,g,b,a
		end)
	self.data = data
	self.height = img:getHeight()
	self.width = img:getWidth()
	self.image = love.graphics.newImage(img)
end

function mask:getWidth()
	return self.width
end

function mask:getHeight()
	return self.height
end

function mask:getPixel(x,y)
	local data = self.data
	if data[x] and data[x][y] then
		return data[x][y]
	else
		return 0
	end
end

function mask:debugDraw()
	if self.image then
		love.graphics.setColor(255,255,255,100)
		love.graphics.draw(self.image)
		love.graphics.setColor(255,255,255)
	end
end

return mask
