local util = {}

function util.distance( x1, y1, x2, y2 )
  local dx = x1 - x2
  local dy = y1 - y2
  return math.sqrt ( dx * dx + dy * dy )
end

function util.realRandom(min, max)
	return love.math.random() * (max - min) + min
end

function util.boxesIntersect(l1,t1,w1,h1, l2,t2,w2,h2)
	return l1 < l2+w2 and l1+w1 > l2 and t1 < t2+h2 and t1+h1 > t2
end

function util.contains(px,py, x,y,w,h)
	return px >= x and px < x + w and py >= y and py < y + h
end

function util.lerp (a, b, t)
    return a + (b - a) * t
end

function util.clamp(val, min,max)
	if val < min then return min
	elseif val > max then return max
	else return val end
end

function util.directionFromVector(vec)

	local v = vec:normalized()

	if v.y < -0.5 then
			return "up"
	elseif v.y > 0.5 then
			return "down"
	elseif v.x > 0 then
			return "right"
	elseif v.x < 0 then
			return "left"
	else
		return nil
	end

end

function util.validDir(dir)
	return dir == "left" or dir == "up" or dir == "right" or dir == "down"
end

function string.trim(s)
  return (s:gsub("^%s*(.-)%s*$", "%1"))
end

function string.starts(String,Start)
  return string.sub(String,1,string.len(Start))==Start
end

function string.ends(String,End)
  return End=='' or string.sub(String,-string.len(End))==End
end

return util
