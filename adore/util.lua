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

adore.util = util

function string.trim(s)
  return (s:gsub("^%s*(.-)%s*$", "%1"))
end

function string.starts(String,Start)
  return string.sub(String,1,string.len(Start))==Start
end

function string.ends(String,End)
  return End=='' or string.sub(String,-string.len(End))==End
end

function love.graphics.roundrect(mode, x, y, width, height, xround, yround)
	xround,yround = 32,32
	local points = {}
	local precision = (xround + yround) * .1
	local tI, hP = table.insert, .5*math.pi
	if xround > width*.5 then xround = width*.5 end
	if yround > height*.5 then yround = height*.5 end
	local X1, Y1, X2, Y2 = x + xround, y + yround, x + width - xround, y + height - yround
	local sin, cos = math.sin, math.cos
	for i = 0, precision do
		local a = (i/precision-1)*hP
		tI(points, X2 + xround*cos(a))
		tI(points, Y1 + yround*sin(a))
	end
	for i = 0, precision do
		local a = (i/precision)*hP
		tI(points, X2 + xround*cos(a))
		tI(points, Y2 + yround*sin(a))
	end
	for i = 0, precision do
		local a = (i/precision+1)*hP
		tI(points, X1 + xround*cos(a))
		tI(points, Y2 + yround*sin(a))
	end
	for i = 0, precision do
		local a = (i/precision+2)*hP
		tI(points, X1 + xround*cos(a))
		tI(points, Y1 + yround*sin(a))
	end
	love.graphics.polygon(mode, unpack(points))
end

