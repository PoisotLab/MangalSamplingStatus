module MangalSuppMatAnalogMaps

using DataFrames
using CSV
using Plots
# using Distances
using SimpleSDMLayers
using Statistics
using ProgressMeter

mangal = CSV.read("networkinfo.dat")

# Remove everything that has a missing latitude, longitude, or bc1
bcdata = dropmissing(mangal, [:latitude, :longitude, :bc1]; disallowmissing = true)
bcdata = bcdata[bcdata.predation .> 0, :]
bcdata.ϕ = bcdata.latitude.*(π/180.0)
bcdata.λ = bcdata.longitude.*(π/180.0)

function haversine(p1, p2, r)
	return acos(sin(p1[2])*sin(p2[2])+cos(p1[2])*cos(p2[2])*cos(p2[1]-p1[1]))*r
	# ACOS(SIN(Lat1)*SIN(Lat2) +COS(Lat1)*COS(Lat2)*COS(Lon2-Lon1)) *6371
end

# Get a template layer and fill it with the haversine distance
bc1 = worldclim(1)
gdis = similar(bc1)
lr = (minimum(bcdata.longitude), maximum(bcdata.longitude))
bt = (minimum(bcdata.latitude), maximum(bcdata.latitude))
gdis = gdis[lr, bt]
all_cells = [(b.λ, b.ϕ) for b in eachrow(bcdata)]
@showprogress for lon in longitudes(gdis)
	for lat in latitudes(gdis)
		cell = (lon*π/180.0, lat*π/180.0)
		if !isnan(gdis[lon,lat])
			all_dist = [haversine(c, cell, 6371.0) for c in all_cells]
			gdis[lon,lat] = mean(sort(all_dist)[1:5])
		end
	end
end

function z!(x::T) where {T <: SimpleSDMResponse}
	μ = mean(filter(!isnan, x.grid))
	σ = std(filter(!isnan, x.grid))
	for i in eachindex(x.grid)
		if !isnan(x[i])
			x.grid[i] = (x.grid[i]-μ)/σ
		end
	end
end

# Add a CAP
for i in eachindex(gdis.grid)
	if gdis.grid[i] > 4000
		gdis.grid[i] = 4000
	end
end

heatmap(longitudes(gdis), latitudes(gdis), gdis.grid, c=:Blues)
savefig(joinpath(@__DIR__, "..", "figures", "figure_04_a.png"))

end
