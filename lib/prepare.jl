import Base: getindex
function getindex(s::T, n::MangalNetwork) where {T <: SimpleSDMLayer}
   lat, lon = latitude(n), longitude(n)
   if ismissing(lat)
      return missing
   end
   if ismissing(lon)
      return missing
   end
   bcval = s[lon, lat]
   if isnan(bcval)
      return missing
   end
   return bcval
end

function haversine(p1, p2, r)
	return acos(sin(p1[2])*sin(p2[2])+cos(p1[2])*cos(p2[2])*cos(p2[1]-p1[1]))*r
end

"""
Normalizes a layer (z-score)
"""
function z!(p::T) where {T <: SimpleSDMResponse}
   d = filter(!isnan, p.grid)
   μ = mean(d)
   σ = std(d)
	for i in eachindex(p.grid)
		if !isnan(p[i])
			p.grid[i] = (p.grid[i]-μ)/σ
		end
	end
end

"""
Normalizes a copy of the layer
"""
function z(p::T) where {T <: SimpleSDMResponse}
   y = copy(p)
   z!(y)
   return y
end

function z(p::T) where {T <: SimpleSDMPredictor}
   return convert(SimpleSDMPredictor, z(convert(SimpleSDMResponse, p)))
end

"""
Normalizes a value (z-score)
"""
function z(v, p::T) where {T <: SimpleSDMLayer}
   @assert typeof(v) <: Number
   d = filter(!isnan, p.grid)
   return (v-mean(d))/std(d)
end

export z, z!

function donwload_shapefile(res)
   @assert res ∈ [50, 100]
   dir = "https://github.com/nvkelso/natural-earth-vector/" *
   "raw/master/$(res)m_physical/"

   fn = "ne_$(res)m_land.shp"
   run(`wget $dir/$fn -P ./assets/`)
end

function worldshape(res)
   pat = joinpath(@__DIR__, "..", "test", "assets", "ne_$(res)m_land.shp")
   handle = open(pat, "r") do io
      read(io, Shapefile.Handle)
   end
   return handle
end
