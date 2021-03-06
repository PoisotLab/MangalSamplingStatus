"""
Normalizes a layer (z-score)
"""
function z!(p::T) where {T <: SimpleSDMResponse}
   d = filter(!isnothing, p.grid)
   μ = mean(d)
   σ = std(d)
	for i in eachindex(p.grid)
		if !isnothing(p[i])
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
   d = filter(!isnothing, p.grid)
   return (v-mean(d))/std(d)
end
