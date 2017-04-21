require('adore.interactable')

local hotspot = adore.class("adore.hotspot", adore.interactable)

function hotspot:initialize(o)
	adore.interactable.initialize(self)
	self.clickable = true
	o = o or {}
	for i,v in pairs(o) do
		self[i] = v
	end
end

adore.hotspot = hotspot
