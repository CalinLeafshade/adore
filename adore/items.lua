local item = adore.class("adore.item")

function item:initialize(uniqueName, name)
	self.uniqueName = uniqueName
	self.name = name
	self.useInv = {}
	local fileName = 'game/gfx/items/' .. uniqueName .. '.png'
	if love.filesystem.exists(fileName) then
		self.sprite = love.graphics.newImage(fileName)
	end
end

function item:interact()
	return false
end

function item:getSprite()
	return self.sprite
end

function item:draw(x,y)
	local sprite = self:getSprite()
	if sprite then
		love.graphics.draw(sprite, x, y)
	end
end

local items = {}

function items.new(uniqueName, name)
  if items[ uniqueName ] then
    error "You've done it wrong, pal."
    return
  end
  local newItem = item(uniqueName, name)
  items[uniqueName] = newItem
  return newItem
end

function items.get(uniqueName)
  return items[uniqueName]
end

function items.load()
	local files = love.filesystem.getDirectoryItems("game/items")
	table.sort(files)
	for i,v in ipairs(files) do
		love.filesystem.load("game/items/" .. v)()
	end
end

adore.items = items
