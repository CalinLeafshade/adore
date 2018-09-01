
p = {
	{1,0,0},
	{1,1,0},
	{0,1,0},
	{0,1,1},
	{0,0,1},
	{1,0,1},
	{1,1,1},
	{0,166/255,81/255},
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

return p
