function haversine(p1, p2, r)
	return acos(sin(p1[2])*sin(p2[2])+cos(p1[2])*cos(p2[2])*cos(p2[1]-p1[1]))*r
end
