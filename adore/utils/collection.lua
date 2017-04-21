
local collection = adore.class('adore.collection')

function collection:initialize()
	self.items = {}
end

function collection:clear()
	self.items = nil
end

function collection:load()
	-- should be overrided to load items
end

function collection:enumerate()
	local fn = coroutine.create(function()
			for i,v in pairs(self.items) do
				coroutine.yield(i,v)
			end
		end)
    return function ()
		_,i,v = coroutine.resume(fn) 
	    return i,v
    end
end

adore.collection = collection