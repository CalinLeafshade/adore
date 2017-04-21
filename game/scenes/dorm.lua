local room = adore.scenes.new("dorm")

room:newObject({
	sprite = "overlay_1",
	clickable = false,
	position = adore.vector(31,138)
})

room:newHotspot({
	name = "Coffee Cup",
	clickable = true,
	interact = function(self)
		aKass:say("First Officer Peterson's mug. In pieces.")
		aKass:say("I'm not sure it's right to disturb a dead man's cup.")
	end
})

room:newHotspot({
	name = "Bunk",
	clickable = true,
	interact = function(self)
		aKass:say("It's where I've slept for the past 156 days.")
		aKass:say("I can't stay there forever.")
	end
})

room:newHotspot({
	name = "Stain",
	clickable = true,
	interact = function(self)
		aKass:say("Where Peterson's mug hit the wall...")
		aKass:say("I think that was the first thing to be smashed.")
	end
})

function room:afterFadeIn()
	if adore.doOnce("showdorm") then
		adore.camera.fadeOut(0)
		adore.wait(1)
		aKass:say("This is the very underwhelming test game")
		adore.camera.fadeIn()
	end
end

function room:repex()
	if Player.position.x < 52 then
		adore.scenes.change("controlroom", 247,108,"down")
	end
end

return room
