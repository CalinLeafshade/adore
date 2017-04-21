
local changeDialog = nil

local function makeChangeRoomDialog()
	local scenes = {}
	for i,v in adore.scenes.enumerate() do
		table.insert(scenes, v)
	end
	table.sort(scenes, function(a,b) return a.name < b.name end)
	local gui = adore.ui.gui({
			x = 0,
			y = 0,
			width = 900,
			height = 950
		})
	
	gui:centre()
	
	local list = adore.ui.listbox(gui, {
			x = 10,
			y = 10,
			width = 880,
			height = 840,
			items = scenes
		})
	
	local cancelButton = adore.ui.button(gui, {
			x = 10,
			y = 860,
			width = 330,
			height = 80,
			text = "Cancel"
		})
	
	local okButton = adore.ui.button(gui, {
			x = 560,
			y = 860,
			width = 330,
			height = 80,
			text = "Ok"
		})
	
	okButton:on("click", function(but)
			local room = list:getSelectedItem()
			if room then
				Player:setScene(room.name)
				adore.scenes.change(room.name)
			end
			changeDialog = nil
			but.parent:destroy()
		end)
	
	cancelButton:on("click", function(but)
			changeDialog = nil
			but.parent:destroy()
		end)
	
end

function adore.debug.showChangeRoomDialog()
	if not changeDialog then
		changeDialog = makeChangeRoomDialog()
	end
end
		