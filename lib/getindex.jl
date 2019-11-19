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
