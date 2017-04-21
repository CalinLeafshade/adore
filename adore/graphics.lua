
-- GRAPHICS API

local colour = adore.class("adore.colour")

function colour:initialize(r,g,b,a)
	self.r = r
	self.g = g
	self.b = b
	self.a = a
end

function colour:unpack()
	return {self.r, self.g, self.b, self.a}
end
	
local graphics = {}

local fonts = {}

local function loadFonts( directory ) 
	
	local fileList = love.filesystem.getDirectoryItems(directory)
	
	for i,fileName in ipairs(fileList) do
		local fontName = string.sub(fileName, string.find(fileName, "[^.]*"))
		
		if fonts[fontName] then
			print("Error! Multiple fonts with same name!")
		else
			print("Loaded font '" .. fontName .. "' at '" .. fileName .. "'")
			fonts[fontName] = directory .. "/" .. fileName
		end
		
	end

end

-- Define the colours table
graphics.colours = {
	white = colour( 255, 255, 255 ),
	black = colour( 0, 0, 0 )
}

-- Load all fonts
function graphics.load()
	
	-- Load the Adore fonts
	loadFonts( "adore/fonts" )
	
	-- Load the game fonts
	loadFonts( "game/fonts" )
	
end

function graphics.getNativeWidth() 
	return love.graphics.getWidth()
end

function graphics.getNativeHeight() 
	return love.graphics.getHeight()
end

function graphics.getHeight()
	return adore.getGame().config.resolution[2]
end

function graphics.getWidth()
	return adore.getGame().config.resolution[1]
end

function graphics.newFont( fontName, fontSize )

	if type(fontName) == "number" then
		return love.graphics.newFont(fontName)
	end

	if not fonts[fontName] then
		print( "Unknown font " .. fontName )
		return
	end

	print("Creating font for '" .. fontName .. "' at size " .. fontSize)

	local fontPath = fonts[fontName]
	return love.graphics.newFont(fontPath, fontSize)

end

function graphics.print(string, font, colour, x, y)

	love.graphics.setColor(colour.r, colour.g, colour.b, colour.a)
	love.graphics.setFont(font)

	love.graphics.print(string,x,y)

end

function graphics.printf(string, font, colour, x, y, limit, align, r, sx, sy, ox, oy, kx, ky)
	
	love.graphics.setColor(colour.r or colour[1], colour.g or colour[2], colour.b or colour[3], colour.a or colour[4])
	love.graphics.setFont(font)
	love.graphics.printf(string, x, y, limit, align, r, sx, sy, ox, oy, kx, ky )

end

function graphics.rectangle(x, y, width, height, filled, colour)

	local mode
	
	if filled then
		mode = "fill"
	else
		mode = "line"
	end

	love.graphics.setColor(colour.r, colour.g, colour.b, colour.a)

	love.graphics.rectangle(mode, x, y, width, height)

end

function graphics.draw(drawable, x, y, r, sx, sy, ox, oy, kx, ky)
	love.graphics.draw(drawable, x, y, r, sx, sy, ox, oy, kx, ky)
end

function graphics.setShader(shader)
	love.graphics.setShader(shader)
end

function graphics.setScissor(x, y, width, height)
	love.graphics.setScissor(x, y, width, height)
end

function graphics.colour(r,g,b,a)
	return colour(r,g,b,a)
end

function graphics.newImage(...)
	return love.graphics.newImage(...)
end

adore.graphics = graphics
		