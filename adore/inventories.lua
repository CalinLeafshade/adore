
-- INVENTORY OBJECTS

local inventory = adore.class("adore.inventory")

inventory:include(adore.persist.mixin.persistable)

function inventory:initialize(owner)

	self.owner = owner
	self.objects = {}

	-- All inventories are persisted
	adore.persist.register(self.owner .. "_inventory", self)

end

function inventory:addItem(item)

	if self.objects[item.uniqueName] then
		self.objects[item.uniqueName].count = self.objects[item.uniqueName].count + 1
	else
		self.objects[item.uniqueName] = { item = item, count = 1 }
	end

	adore.runEvent("onInventoryItemAdded", self.owner, item)

end

function inventory:hasItem( item )
	if self:countItem(item) > 0 then
		return true
	else
		return false
	end
end

function inventory:countItem( item )
	local uniqueName
	if type(item) == "string" then
		uniqueName = item
	else
		uniqueName = item.uniqueName
	end

	if not self.objects[uniqueName] then
		return 0
	else
		return self.objects[uniqueName].count
	end

end

function inventory:removeItem( item )
	self:removeItem( item, 1 )
end

function inventory:removeItem( item, count )

	local uniqueName
	if type(item) == "string" then
		uniqueName = item
	else
		uniqueName = item.uniqueName
	end

	count = count or 1

	if self.objects[uniqueName] then
		self.objects[uniqueName].count = self.objects[uniqueName].count - count

		if self.objects[uniqueName].count == 0 then
			self.objects[uniqueName] = nil
		end
	end


end

function inventory:getItems()
  return self.objects
end

function inventory:getPersistenceKeys()
	return {
		-- Serialize our object table.
		-- This requires getters and setters as we cant(/don't want to) serialize
		-- the entire item class.
		{ "objects",
			-- Get a serializable version - [ { key : count }, { key : count } ]
			function (x)
				local objects = {}
				for k,v in pairs(x) do
					objects[k] = v.count
				end

				return objects
			end,
			-- Convert the serializable version back into something we want.
			function (x)
				local objects = {}
				for k,v in pairs(x) do
					local item = adore.items.get(k)
					objects[k] = { item = item, count = v }
				end
				return objects
			end
		}
	}
end

local inventories = {}

function inventories.new(owner)
  return inventory(owner)
end

return inventories
