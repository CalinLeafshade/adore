
local overlay = adore.class("adore.overlay")

function overlay:initialize(zindex)
	self.enabled = false
	self.z = zindex
end

function overlay:enable()
	self.enabled = true
end

function overlay:disable()
	self.enabled = false
end

function overlay:isEnabled()
	return self.enabled
end

function overlay:draw()
end

function overlay:update(dt)
end

function overlay:getZIndex()
	return self.z
end

function overlay:setZIndex(z)
	self.z = z
end

local overlays = {}

local overlayList = {}

local overlayZList = {}

function overlays.newOverlayType(subclassName)
	return adore.class(subclassName, overlay)
end

overlays.base = overlay

-- Update in any order
function overlays.update(dt)

	for key, overlay in ipairs(overlayList) do
		if overlay:isEnabled() then
			overlay:update(dt)	
		end
	end

end

-- Always draw in z-index order
function overlays.draw()

	for key, overlay in ipairs(overlayList) do
		if overlay:isEnabled() then
			overlay:draw()
		end
	end

end

function overlays.add(overlay)

	table.insert(overlayList, overlay)
	table.sort(overlayList, function(a,b)
			return a:getZIndex() < b:getZIndex()
	end)

end

function overlays.remove(overlayToRemove)
	
	for key, overlay in ipairs(overlayList) do
		if overlay == overlayToRemove then
			table.remove(overlayList, key)
		end
	end

end

-- Set up some z indexes
overlays.z = {}
overlays.z.MAX = 100
overlays.z.ADORE_RANGE_START = 200
overlays.z.ADORE_FADESCREEN = overlays.z.ADORE_RANGE_START + 1

adore.overlays = overlays
