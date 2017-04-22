local persistable = {

	-- INTERNAL USE - persist a given set of keys. The keys should be
	-- an array of strings and tables.  Strings are stored as keys, tables are
	-- accessed such that: Index 1 is the key. Index 2 is a "builder" function.
	_adore_persistKeys = function (self, keys)

		-- Register some internal use functions.
		self._adore_persisted = {}
		self._adore_persisted_getters = {}
		self._adore_persisted_setters = {}

		for k,v in ipairs(keys) do

			-- If the key is actually a table, then it must have a setter and/or getter.
			if type(v) == "table" then
				-- Index 1 is the key.
				table.insert(self._adore_persisted, v[1])

				-- Index 2 is the getter.
				self._adore_persisted_getters[v[1]] = v[2]

				-- Index 3 is the setter.
				self._adore_persisted_setters[v[1]] = v[3]
			else
				table.insert(self._adore_persisted, v)
			end
		end

	end,

	-- INTERNAL USE. Return the values which need to be persisted
	_adore_getPersistableTable = function (self)
		local persistedTable = {}
		for k,v in ipairs(self._adore_persisted) do
			if self._adore_persisted_getters[v] then
				persistedTable[v] = self._adore_persisted_getters[v](self[v])
			else
				persistedTable[v] = self[v]
			end
		end

		return persistedTable
	end,

	-- INTERNAL USE. Restore the persisted values.
	_adore_setPersistedTable = function(self, persistedTable)
		self:prepareForReload()
		for k,v in pairs(persistedTable) do
			if self._adore_persisted_setters[k] then
				self[k] = self._adore_persisted_setters[k](v)
			else
				self[k] = v
			end
		end
	end,

	-- Default implementation.
	prepareForReload = function(self)

		-- do nothing.

	end


}

local persistedObjects = {}
local persist = {}

persist.mixin = { persistable = persistable }

function persist.register(key, item)

	persistedObjects[key] = item

	item:_adore_persistKeys( item:getPersistenceKeys() )

end

function persist.save()

	local saveData = {}

	for k,v in pairs(persistedObjects) do
		saveData[k] = v:_adore_getPersistableTable()
	end

	local game = adore.getGame()

	if game.state then
		saveData["_adore_game_state"] = game.state
	end

	local out = json.encode(saveData)

	love.filesystem.write("jake.sav", out)
end

function persist.load()

	local inS = love.filesystem.read("jake.sav")

	local saveData = json.decode(inS)

	for k,v in pairs(saveData) do
		if k == "_adore_game_state" then
			adore.getGame().state = v
		else
			persistedObjects[k]:_adore_setPersistedTable(v)
		end
	end

end

return persist
