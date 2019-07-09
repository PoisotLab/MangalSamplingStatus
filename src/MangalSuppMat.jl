module MangalSuppMat

using Statistics
using SimpleSDMLayers

greet() = print("Hello World!")

function haversine(p1, p2, r)
	return acos(sin(p1[2])*sin(p2[2])+cos(p1[2])*cos(p2[2])*cos(p2[1]-p1[1]))*r
end
export haversine

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

end # module
