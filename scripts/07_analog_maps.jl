using DataFrames
using CSV
using Plots
using SimpleSDMLayers
using Statistics

include(joinpath("..", "lib", "haversine.jl"))
include(joinpath("..", "lib", "zscores.jl"))

mangal = CSV.read(joinpath("data", "network_data.csv"))

# Remove everything that has a missing latitude, longitude, or bc1
bcdata = dropmissing(mangal, [:latitude, :longitude, :bc1]; disallowmissing = true)
bcdata.ϕ = bcdata.latitude.*(π/180.0)
bcdata.λ = bcdata.longitude.*(π/180.0)

prdata = bcdata[bcdata.predation .> 0, :]
padata = bcdata[bcdata.parasitism .> 0, :]
mudata = bcdata[bcdata.mutualism .> 0, :]

# Get a template layer and fill it with the haversine distance
bc = worldclim(1:19; resolution="10")
zbc = [z(b) for b in bc]
bc1 = bc[1]

prgdis = similar(bc1)
prbdis = similar(bc1)

pagdis = similar(bc1)
pabdis = similar(bc1)

mugdis = similar(bc1)
mubdis = similar(bc1)

for i in 1:19
	nc = Symbol("zbc"*string(i))
	oc = Symbol("bc"*string(i))
	prdata[nc] = [z(v, bc[i]) for v in prdata[oc]]
	padata[nc] = [z(v, bc[i]) for v in padata[oc]]
	mudata[nc] = [z(v, bc[i]) for v in mudata[oc]]
end

bc_colnames = Symbol.("zbc".*string.(1:19))

pr_bc_webs = convert(Matrix, prdata[:,bc_colnames])
pa_bc_webs = convert(Matrix, padata[:,bc_colnames])
mu_bc_webs = convert(Matrix, mudata[:,bc_colnames])

all_cells = [(b.λ, b.ϕ) for b in eachrow(prdata)]
for lon in longitudes(prgdis)
	for lat in latitudes(prgdis)
		cell = (lon*π/180.0, lat*π/180.0)
		if !isnan(prgdis[lon,lat])
			cell_bc_values = [zb[lon,lat] for zb in zbc]
			cell_bc_distance = vec(sum(sqrt.((pr_bc_webs.-cell_bc_values').^2.0); dims=2))
			all_dist = [haversine(c, cell, 6371.0) for c in all_cells]
			prgdis[lon,lat] = mean(sort(all_dist)[1:5])
			prbdis[lon,lat] = log(mean(sort(cell_bc_distance)[1:5])+1.0)
		end
	end
end

heatmap(prgdis, c=:Greens, frame=:box, dpi=200, frame=:box)
savefig(joinpath("figures", "geodistance_predation.png"))
heatmap(prbdis, c=:Greens, frame=:box, clim=(0.0,4.5), dpi=200, frame=:box)
savefig(joinpath("figures", "envirodistance_predation.png"))

all_cells = [(b.λ, b.ϕ) for b in eachrow(padata)]
for lon in longitudes(pagdis)
	for lat in latitudes(pagdis)
		cell = (lon*π/180.0, lat*π/180.0)
		if !isnan(pagdis[lon,lat])
			cell_bc_values = [zb[lon,lat] for zb in zbc]
			cell_bc_distance = vec(sum(sqrt.((pa_bc_webs.-cell_bc_values').^2.0); dims=2))
			all_dist = [haversine(c, cell, 6371.0) for c in all_cells]
			pagdis[lon,lat] = mean(sort(all_dist)[1:5])
			pabdis[lon,lat] = log(mean(sort(cell_bc_distance)[1:5])+1.0)
		end
	end
end

heatmap(pagdis, c=:Oranges, dpi=200, frame=:box)
savefig(joinpath("figures", "geodistance_parasitism.png"))
heatmap(pabdis, c=:Oranges, clim=(0,4.5), dpi=200, frame=:box)
savefig(joinpath("figures", "envirodistance_parasitism.png"))

all_cells = [(b.λ, b.ϕ) for b in eachrow(mudata)]
for lon in longitudes(mugdis)
	for lat in latitudes(mugdis)
		cell = (lon*π/180.0, lat*π/180.0)
		if !isnan(mugdis[lon,lat])
			cell_bc_values = [zb[lon,lat] for zb in zbc]
			cell_bc_distance = vec(sum(sqrt.((mu_bc_webs.-cell_bc_values').^2.0); dims=2))
			all_dist = [haversine(c, cell, 6371.0) for c in all_cells]
			mugdis[lon,lat] = mean(sort(all_dist)[1:5])
			mubdis[lon,lat] = log(mean(sort(cell_bc_distance)[1:5])+1.0)
		end
	end
end

heatmap(mugdis, c=:Blues, dpi=200, frame=:box)
savefig(joinpath("figures", "geodistance_mutualism.png"))
heatmap(mubdis, c=:Blues, clim=(0,4.5), dpi=200, frame=:box)
savefig(joinpath("figures", "envirodistance_mutualism.png"))

plot(
	heatmap(prbdis, c=:Blues, clim=(0,4.5), dpi=200, frame=:box),
	heatmap(pabdis, c=:Blues, clim=(0,4.5), dpi=200, frame=:box),
	heatmap(mubdis, c=:Blues, clim=(0,4.5), dpi=200, frame=:box),
	layout=(3,1)
)
savefig(joinpath("figures", "combined_envirodist_maps.pdf"))
