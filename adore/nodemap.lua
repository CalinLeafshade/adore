local pathnode = adore.class('pathnode')

function pathnode:initialize(x,y, maskId)
	self.x = x
	self.y = y
	self.neighbours = {}
	self.maskId = maskId
end

function pathnode:addNeighbour(node)
	table.insert(self.neighbours, node)
end

function pathnode.asString(x,y)
	return "Pathnode: " .. x .. "," .. y
end

function pathnode:__tostring()
	return pathnode.asString(self.x, self.y)
end

local nodelookuptable = adore.class("nodelookuptable")

function nodelookuptable:initialize()
	self.lookup = {}
end

-- Add the given node to the look up table.
function nodelookuptable:put(node)
	if not self.lookup[node.x] then
		self.lookup[node.x] = {}
	end

	self.lookup[node.x][node.y] = node
end

-- Get a node from the look up table.
function nodelookuptable:get(x,y)
	if not self.lookup[x] then
		return nil
	end

	return self.lookup[x][y]
end

local step = 2

local nodemap = adore.class('nodemap')

-- Initialize a node map
function nodemap:initialize(mask)

	-- Table to store the found nodes.
	-- Should be treated as an array, and inserted with table.insert
	local nodes = { }
	self.maskIds = {}

	-- Table for node look ups.
	-- Hash table in the format lookup[x][y].
	-- Use addToLookup and getFromLookup to access.
	local lookup = nodelookuptable()

	-- Check if a given x,y is masked
	local function isMasked(mask, x,y)
		return mask:getPixel(x,y)
	end

	-- Look all x,y values.
	for y = 0, mask:getHeight() - 1, step do
		for x = 0, mask:getWidth() - 1, step do

			local maskId = isMasked(mask, x, y)
			if maskId > 0 then

				self.maskIds[maskId] = true
				self.minY = self.minY or y
				self.maxY = y
				-- This is a masked pixel
				local node = pathnode(x,y, maskId)
				table.insert(nodes, node)

				lookup:put(node)

				-- Check the neighbours above and to the left of this node.
				-- NOTE: If we ever don't start at (0,0) this code will need to change.
				for xOffset=-step,0,step do
					for yOffset=-step,0,step do
						if not (xOffset == 0 and yOffset == 0) then
							local neighbour = lookup:get(x + xOffset, y + yOffset)

							if neighbour then
								-- Tag the relation on both nodes
								node:addNeighbour(neighbour)
								neighbour:addNeighbour(node)
							end
						end
					end
				end
			end
		end
	end

	self.nodes = nodes

end

function nodemap:draw()
	for i,v in ipairs(self.nodes) do
		love.graphics.circle("fill", v.x,v.y,2)
	end
end

local function dist(x1,y1,x2,y2) return math.sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2) end

function nodemap:closest(x,y, excludedDict)
	excludedDict = excludedDict or {}
	local dd = math.huge
	for i,v in ipairs(self.nodes) do
		if not excludedDict[v.maskId] then
			local d = dist(x,y,v.x,v.y)
			if d < dd then
				dd = d
				closest = v
			end
		end
	end
	return closest
end

function nodemap:path(fromX, fromY, toX, toY, excludedMasks)

	local excludedMaskIds = {}

	if excludedMasks then
		for i,v in ipairs(excludedMasks) do
			 excludedMaskIds[v] = true
			print(v)
		end
	end

	local start = self:closest(fromX, fromY, excludedMaskIds)
	local goal = self:closest(toX, toY, excludedMaskIds)

	if not start or not goal then
		return nil
	end

	closed = {}
	open = {}
	cameFrom = {}

	open[start] = start

	local function hOf(from, to)
		return dist(from.x, from.y, to.x, to.y)
	end

	local g = {}
	g[start] = 0

	local f = {}
	f[start] = g[start] + hOf(start, goal)

	local function lowestF()
		local lowestVal = math.huge
		local lowestNode = nil
		for i,v in pairs(open) do
			if f[v] < lowestVal then
				lowestVal = f[v]
				lowestNode = v
			end
		end
		return lowestNode
	end

	local function itemsInOpenSet()
		for i,v in pairs(open) do
			return true
		end
		return false
	end

	local function reconstructPath(flat_path, map, current_node)
		if map [current_node] then
			table.insert (flat_path, 1, map [current_node])
			return reconstructPath(flat_path, map, map[current_node])
		else
			return flat_path
		end
	end

	while itemsInOpenSet() do

		local current = lowestF()
		if current == goal then
			return reconstructPath({}, cameFrom, goal)
		end

		open[current] = nil
		closed[current] = current

		for i,v in ipairs(current.neighbours) do
			if not closed[v] then
				local tentativeG = g[current] + dist(current.x, current.y, v.x, v.y)

				if (not open[v] or tentativeG < g[v]) and not  excludedMaskIds[v.maskId] then
					cameFrom[v] = current
					g[v] = tentativeG
					f[v] = g[v] + hOf(v, goal)
					open[v] = v
				end
			end

		end

	end

	return false
end

return nodemap
