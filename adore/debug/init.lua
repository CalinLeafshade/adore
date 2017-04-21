
-- DEBUG OBJECTS

local timer = adore.class("adore.debug.timer")

function timer:initialize()
	self.marks = {}
end

function timer:start()
	self.marks.start = love.timer.getTime()
end

function timer:stop()
	self.marks.stop = love.timer.getTime()
end

function timer:mark(mark)
	self.marks[mark] = love.timer.getTime()
end

function timer:delta(startMark, stopMark)
	local output = self.marks[stopMark] - self.marks[startMark]

	return math.floor( (output * 1000) + .5) / 1000
end

local debug = {}

function debug.newTimer() 
	return timer()
end

debug.enabled = false

adore.debug = debug

require('adore.debug.changeroom')
