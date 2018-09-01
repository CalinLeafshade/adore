
aKass = adore.actors.new("Kass")

aKass.walkSet =
{
	left = adore.animation("aKassLeft", "aKass/right.png", nil, 9, 1, 9, 3, true),
	right = adore.animation("aKassRight", "aKass/right.png", nil,9, 1, 9, 3, false),
	up = adore.animation("aKassUp", "aKass/back.png", nil, 9, 1, 9, 3, false),
	down = adore.animation("aKassDown", "aKass/front.png", nil, 9, 1, 9, 3, false)
}

aKass.position.y = 100
aKass.position.x = 160

aKass:face("down")

Player = aKass

aKass:setScene("descent")
