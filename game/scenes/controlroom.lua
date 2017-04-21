local room = adore.scenes.new("controlroom")

room:newObject({
	sprite = "overlay_1",
	clickable = false,
	position = adore.vector(5,157)
})

room:newObject({
	sprite = "overlay_2",
	clickable = false,
	position = adore.vector(11,137)
})

room:newHotspot({
	name = "Fire Extinguisher",
	clickable = true,
	interact = function(self)
		aKass:say("Used to put out fires.")
		aKass:say("Even with everything that happened, we didn't have a single fire.")
	end
})

room:newHotspot({
	name = "Screen",
	clickable = true,
	interact = function(self)
		aKass:say("It's a screen showing the stations vitals.")
		aKass:say("We are 8,345m below sea level according to this.")
	end
})

room:newHotspot({
	name = "Chair",
	clickable = true,
	interact = function(self)
		aKass:say("That's where Ensign Murphy used to sit.")
	end
})

return room
