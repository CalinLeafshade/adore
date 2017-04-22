require "adore.overlays.screenfadeoverlay"

local camera = { x = 0, y = 0, targetX = 0, targetY = y, scale = 1, rot = 0 }

local screenFadeOverlay = screenfadeoverlay()

adore.overlays.add(screenFadeOverlay)

-- Are we currently faded?
local faded = false

-- Fade overlay alpha.
local fadeOverlayAlpha = 0

function camera.followActor(a)
	camera.following = a
end

function camera.update(dt)
	if camera.following then
		local x, y = camera.following:getPosition()
		camera.moveTo(x,y, false)
	end
	camera.x = adore.util.lerp(camera.x, camera.targetX, dt)
	camera.y = adore.util.lerp(camera.y, camera.targetY, dt)
	camera.clamp()
end

function camera.clamp()
	local res = adore.getGame().config.resolution
	local scene = adore.scenes.getCurrent()
	if scene and res then
		camera.x = adore.util.clamp(camera.x, res[1] / 2, scene:getWidth() - res[1] / 2)
		camera.y = adore.util.clamp(camera.y, res[2] / 2, scene:getHeight() - res[2] / 2)
	end
end

function camera.topLeft()
	local res = adore.getGame().config.resolution
	return camera.x - res[1] / 2, camera.y - res[2] / 2
end

function camera.toRoom(x,y)
	local l, t = camera.topLeft()
	return math.floor(x + l), math.floor(y + t)
end

function camera.attach()
	camera.clamp()
	local cx,cy = adore.getGame().config.resolution[1]/(2*camera.scale), adore.getGame().config.resolution[2]/(2*camera.scale)
	love.graphics.push()
	love.graphics.scale(camera.scale)
	love.graphics.translate(math.floor(cx), math.floor(cy))
	love.graphics.rotate(camera.rot)
	--love.graphics.translate(-camera.x, -camera.y)
	love.graphics.translate(-math.floor(camera.x), -math.floor(camera.y))
end

function camera.detach()
	love.graphics.pop()
end

function camera.getPosition()
	return camera.x, camera.y
end

function camera.moveTo(x,y, snap)
	camera.targetX = x
	camera.targetY = y
	if snap then
		camera.x = x
		camera.y = y
	end
end

function camera.fadeOut(speed)
	screenFadeOverlay:fadeOut(speed or 1)
end

function camera.fadeIn(speed)
	screenFadeOverlay:fadeIn(speed or 1)
end

return camera
