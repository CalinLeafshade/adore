local astar = require('adore.lib.astar')
local path = adore.class("adore.path")

function path:initialize(room,fromX,fromY,toX,toY)

	self.map = room.nodemap
	self.room = room

	if not self.map then
		self.unreachable = true
		return
	end

	local excludedIDs = {}
	for i,v in pairs(self.room.disabledWalkableAreas) do
		table.insert(excludedIDs, i)
	end

	local path = self.map:path(fromX, fromY, toX, toY, excludedIDs)
	if not path then
		self.unreachable = true
		return
	end
	for i,v in ipairs(path) do
		self[i] = v
	end
	self:optimize()
end

local function isWalkableBetween(room,p1,p2,step,spread)
	step = step or 0.2
	local stepVec = (p2-p1):normalized() * step
	local testPoint = p1:clone()
	local testPointL = p1 + adore.vector(p1.y,-p1.x):normalized() * spread
	local testPointR = p1 + adore.vector(-p1.y,p1.x):normalized() * spread
	local tests = {}
	testPoint = testPoint + stepVec
	testPointL = testPointL + stepVec
	testPointR = testPointR + stepVec
	local function test(p,tests)
		local x,y = math.floor(p.x) + 1, math.floor(p.y) + 1
		table.insert(tests, {x,y})
		if not room:isWalkable(x,y) then
			return false
		end
		return true
	end
	while testPoint:dist(p2) > step do
		if not test(testPointL,tests) then
			return false, tests
		end
		if not test(testPointR,tests) then
			return false, tests
		end
		if not test(testPoint,tests) then
			return false, tests
		end
		testPoint = testPoint + stepVec
		testPointL = testPointL + stepVec
		testPointR = testPointR + stepVec
	end
	return true,tests
end

function path:optimize()
	self.pathCopy = {}
	for i,v in ipairs(self) do
		self.pathCopy[i] = self[i]
	end
	local i = 2
	local squareTests = {}
	while i < #self do
		local ok, tests = isWalkableBetween(self.room,adore.vector(self[i-1].x,self[i-1].y), adore.vector(self[i+1].x,self[i+1].y),10,2)
		for i,v in ipairs(tests or {}) do
			table.insert(squareTests,v)
		end
		if ok then
			table.remove(self,i)
		else
			i = i + 1
		end
	end
	self.optimPathCopy = {}
	for i,v in ipairs(self) do
		self.optimPathCopy[i] = self[i]
	end
	--self.optimTests = squareTests
end

function path:next()
	return table.remove(self,1)
end

function path:peek()
	return self[1]
end

function path:draw()
	local function drawPath(p)
		if not p then return end
		if #p < 2 then return end
		local verts = {}
		for i,v in ipairs(p) do
			local x,y = v.x,v.y
			table.insert(verts,x)
			table.insert(verts,y)
		end
		love.graphics.line(unpack(verts))
	end
	love.graphics.setColor(255,0,0)
	drawPath(self.pathCopy)
	love.graphics.setColor(0,255,0)
	--drawPath(self.optimPathCopy)
	if self.optimTests then
		local drawn = {}
		love.graphics.setColor(0,0,255,128)
		--print(#self.optimTests)
		for i,v in ipairs(self.optimTests) do
			local x,y = v[1],v[2]
			if not drawn[x .."," .. y] then
				drawn[x .."," .. y] = true
				love.graphics.point(x,y)
			end
		end
	end
end

return path
