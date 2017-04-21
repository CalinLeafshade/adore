local sceneObject = adore.class("adore.sceneObject")

function sceneObject:initialize(o)
	self.visible = true
	self.clickable = true
	o = o or {}
	for i,v in pairs(o) do
		self[i] = v
	end
end

adore.sceneObject = sceneObject
