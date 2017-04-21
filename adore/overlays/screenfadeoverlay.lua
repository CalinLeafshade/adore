screenfadeoverlay = adore.overlays.newOverlayType("adore.screenfadeoverlay")

-- This overlay is responsible for fading the screen in and out
function screenfadeoverlay:initialize()
	adore.overlays.base.initialize(self, adore.overlays.z.ADORE_FADESCREEN)
	self.colour = adore.graphics.colours.black
	self.easingFunc = nil
	self.alphaFunc = nil
	
	-- Is the screen currently faded?
	self.faded = false

end

function screenfadeoverlay:update(dt)

	self.time = math.min( self.fadeSpeed, self.time + dt )	

	-- Override if fadeSpeed is 0 - the easing functions dont work, so skip straight to full
	local ease
	
	if self.fadeSpeed == 0 then
		ease = 255
	else
		ease = self.easingFunc( self.time, 0, 255, self.fadeSpeed )
	end

	self.colour.a = self.alphaFunc( ease )
	
	if self.time == self.fadeSpeed then
		self.done = true
	end

end

function screenfadeoverlay:draw(dt)
	
		love.graphics.setColor(self.colour.r, self.colour.g, self.colour.b, self.colour.a)
		love.graphics.rectangle("fill", 0, 0, 1920, 1080)	

end

function screenfadeoverlay:fadeIn(speed)
	
	if not self.faded then return end
	
	self:startFade(speed, adore.easing.inQuad, function (ease) return 255 - ease end )

	self:disable()

	self.faded = false

end

function screenfadeoverlay:fadeOut(speed)
	
	if self.faded then return end
	
	self:startFade(speed, adore.easing.outQuad, function (ease) return ease end )

	self.faded = true

end

function screenfadeoverlay:startFade(speed, easing, alpha)
	
	self.time = 0
	self.fadeSpeed = speed
	self.easingFunc = easing
	self.alphaFunc = alpha
	self.done = false
	self:enable()
	
	while not self.done do
		coroutine.yield()
	end

end

