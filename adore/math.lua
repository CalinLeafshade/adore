local math = {}

--- Clamp a value
-- @param  val Value to clamp
-- @param  mn  Minimum value
-- @param  mx  Maximum value
-- @return     Clamped value
function math.clamp(val, mn, mx)
    if val < mn then return mn
    elseif val > mx then return mx
    else return val
    end
end

function math.saturate(val)
	return math.clamp(val, 0,1)
end

--- Lerps a value
-- @param  a Lower value
-- @param  b Upper value
-- @param  t Needle
-- @return   A lerped value
function math.lerp (a, b, t)
    return a + (b - a) * t
end

--- Smoothsteps a value
-- @param  edge0 Lower edge
-- @param  edge1 Upper edge
-- @param  x     Needle
-- @return       The smoothed value
function math.smoothstep(edge0, edge1, x)
    x = math.saturate((x - edge0) / (edge1 - edge0))
    return x * x * (3 - 2 * x)
end

--- Lerps a value with a smoothed needle
-- @param  a Lower edge
-- @param  b Upper edge
-- @param  t Needle
-- @return   A smoothly lerped value
function math.smoothlerp(a,b,t)
    return math.lerp(a,b,math.smoothstep(0,1,t))
end

function math.contains(x,y,w,h,px,py)

	if px >= x and
		px <= x + w and
		py >= y and
		py <= y + h then
		return true
	end
	return false

end

function math.lerpColor(c1, c2, t)
	return {
		math.lerp(c1[1], c2[1], t),
		math.lerp(c1[2], c2[2], t),
		math.lerp(c1[3], c2[3], t),
		math.lerp(c1[4] or 255, c2[4] or 255, t)
	}
end

function math.dist(x1,y1,x2,y2) return math.sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2) end

function math.round(n) return math.floor(n + 0.5) end

return math
