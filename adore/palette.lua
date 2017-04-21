
p = {
	{255,0,0},
	{255,255,0},
	{0,255,0},
	{0,255,255},
	{0,0,255},
	{255,0,255},
	{255,255,255},
	{0,166,81},
	find = function(r,g,b)
		if type(r) == "table" then
				r,g,b = unpack(r)
		end
		for i,v in ipairs(p) do
			if v[1] == r and v[2] == g and v[3] == b then
				return i
			end
		end
		return nil
	end
}

adore.palette = p