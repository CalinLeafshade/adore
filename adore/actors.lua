require("adore.actor")

-- Actors collection

local actors = {
	lighting = false
}

local loaded = {}

function actors.new(name)
	local o = adore.actor(name)
	loaded[name] = o
	return o
end

function actors.update(dt)
	for i,v in actors.enumerate() do
		v:update(dt)
	end
end

function actors.enumerate()
	local fn = coroutine.create(function()
			for i,v in pairs(loaded) do
				coroutine.yield(i,v)
			end
		end)
    return function ()
		_,i,v = coroutine.resume(fn)
	    return i,v
    end
end

function actors.load()
	local files = love.filesystem.getDirectoryItems("game/actors")
	table.sort(files)
	for i,v in ipairs(files) do
		love.filesystem.load("game/actors/" .. v)()
	end
end

function actors.atRoom(x,y)
	local tests = {}
	for i,v in actors.enumerate() do
		if v:inCurrentRoom() then
			table.insert(tests, v)
		end
	end
	table.sort(tests, function(a,b) return a.position.y < b.position.y end)
	for i,v in ipairs(tests) do
		if v:hitTest(x,y) then
			return v
		end
	end
end

function actors.drawSpeech()
	for k,v in actors.enumerate() do
		if v:inCurrentRoom() then
			v:drawSpeech()
		end
	end
end

return actors
