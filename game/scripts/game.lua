local font = adore.graphics.newFont("opensanslight", 40)

adore.event("on_mouse_press", function(x,y,b)
	local scene = adore.scenes.getCurrent()
	local sx,sy = adore.camera.toRoom(x,y)
	if scene:onClick(sx,sy,b) then
		return
	end
	local hit = scene:query(sx,sy)
	if b == 1 then -- Left mouse button
		if not hit then
			aKass:walk(sx,sy)
		elseif hit.clickable then
			if type(hit.interact) == "function" then
				hit.interact()
			end
		end
	elseif b == 2 then -- Right mouse button

	end
end)

adore.event("on_key_press", function(key)

	if key == "i" then

		local kassInventory = aKass.inventory
		local itemList = "Looks like I have: "

		for k,v in pairs(kassInventory:getItems()) do
			itemList = itemList .. v.item.name .. " (" .. v.count .. ")"
		end

		aKass:say(itemList)

	elseif key == "q" then
		adore.quit()
	elseif key == "f" then
		adore.camera.fadeOut(1)
	elseif key == "g" then
		adore.camera.fadeIn(1)
	elseif key == "h" then
		adore.camera.fadeOut(1)
		adore.camera.fadeIn(1)
	elseif key == "s" then
		adore.persist.save()
	elseif key == "r" then
		adore.persist.load()
	elseif key == "f9" then
		adore.reloadAssets()
	end

end)

local showingHotspot = false
local hotspotY = adore.graphics.getNativeHeight()
local hotspotOpacity = 0
local text = ""

adore.event("repeatedly_execute_always", function()
		local obj, t = adore.queryScreen(adore.mouse.getPosition())

		showingHotspot = false

		if not adore.isBlocked() and obj and obj.clickable and t ~= "ui" then
			text = obj.name
			showingHotspot = true
		end

		if adore.isBlocked() then
			showingHotspot = false
		end

		local w = adore.graphics.getNativeWidth()
		local h = adore.graphics.getNativeHeight()
		local textHeight = 100
		hotspotY = adore.math.lerp(hotspotY, showingHotspot and h - textHeight or h, 1/5)
		hotspotOpacity = ( 1 -(hotspotY - (h - textHeight)) / textHeight) * 255
	end)

adore.event("nativeDraw", function()
		local w = adore.graphics.getNativeWidth()
		adore.graphics.printf(text or "", font, {255,255,255,hotspotOpacity}, 0, hotspotY, w, "center")
	end)
