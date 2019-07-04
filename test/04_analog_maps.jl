module MangalSuppMatAnalogMaps

using DataFrames
using CSV
using Plots
using Distances
using SimpleSDMLayers
using Statistics

mangal = CSV.read("networkinfo.dat")

# Remove everything that has a missing latitude, longitude, or bc1
bcdata = dropmissing(mangal, [:latitude, :longitude, :bc1]; disallowmissing = true)
bcdata.ϕ = bcdata.latitude.*(π/180.0)
bcdata.λ = bcdata.longitude.*(π/180.0)

# Get a template layer and fill it with the haversine distance
bc1 = worldclim(1)
gdis = similar(bc1)
lr = (minimum(bcdata.longitude), maximum(bcdata.longitude))
bt = (minimum(bcdata.latitude), maximum(bcdata.latitude))
gdis = gdis[lr, bt]
for lon in longitudes(gdis)
   for lat in latitudes(gdis)
      if !isnan(gdis[lon,lat])
         cell = (lon*π/180.0, lat*π/180.0)
         all_dist = [haversine((b.λ, b.ϕ), cell, 6971.0) for b in eachrow(bcdata)]
         gdis[lon,lat] = mean(sort(all_dist)[1:3])
      end
   end
end

heatmap(gdis.grid)
savefig(joinpath(@__DIR__, "..", "figures", "figure_04_a.png"))

end
