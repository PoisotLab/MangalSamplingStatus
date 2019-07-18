module MangalSuppMatAnalogMaps

using MangalSuppMat

using DataFrames
using CSV
using Plots
using SimpleSDMLayers
using Statistics
using ProgressMeter

mangal = CSV.read("network_data.dat")

# Remove everything that has a missing latitude, longitude, or bc1
bcdata = dropmissing(mangal, [:latitude, :longitude, :bc1]; disallowmissing = true)
bcdata = bcdata[bcdata.predation .> 0, :]
bcdata.ϕ = bcdata.latitude.*(π/180.0)
bcdata.λ = bcdata.longitude.*(π/180.0)

# Get a template layer and fill it with the haversine distance
bc = worldclim(1:19; resolution="10")
zbc = [z(b) for b in bc]
bc1 = bc[1]

gdis = similar(bc1)
bdis = similar(bc1)

for i in 1:19
   nc = Symbol("zbc"*string(i))
   oc = Symbol("bc"*string(i))
   bcdata[nc] = [z(v, bc[i]) for v in bcdata[oc]]
end

bc_colnames = Symbol.("zbc".*string.(1:19))
bc_webs = convert(Matrix, bcdata[:,bc_colnames])


all_cells = [(b.λ, b.ϕ) for b in eachrow(bcdata)]
@showprogress for lon in longitudes(gdis)
	for lat in latitudes(gdis)
		cell = (lon*π/180.0, lat*π/180.0)
		if !isnan(gdis[lon,lat])
         cell_bc_values = [zb[lon,lat] for zb in zbc]
         cell_bc_distance = vec(sum(sqrt.((bc_webs.-cell_bc_values').^2.0); dims=2))
			all_dist = [haversine(c, cell, 6371.0) for c in all_cells]
			gdis[lon,lat] = mean(sort(all_dist)[1:5])
         bdis[lon,lat] = mean(sort(cell_bc_distance)[1:5])
		end
	end
end

# Add a CAP at 4000 km
# for i in eachindex(gdis.grid)
	# if gdis.grid[i] > 4000
		# gdis.grid[i] = 4000
	# end
# end

heatmap(longitudes(gdis), latitudes(gdis), gdis.grid, c=:PuBu)
savefig(joinpath(@__DIR__, "..", "figures", "figure_03_a.png"))

heatmap(longitudes(bdis), latitudes(bdis), log10.(bdis.grid.+1.0), c=:YlGnBu)
savefig(joinpath(@__DIR__, "..", "figures", "figure_03_b.png"))

end
