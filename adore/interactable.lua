
local interactable = adore.class("adore.interactable")

function interactable:initialize()
	self.useInv = {}
	self.interact = function() end
	self.enabled = true
end

adore.interactable = interactable