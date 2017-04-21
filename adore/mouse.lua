local mouse = 
	{
		x = 0, y = 0
	}

function mouse.getPosition()
	return mouse.x, mouse.y
end

function mouse.getY()
	return mouse.y
end

adore.mouse = mouse