using DataFrames
using CSV
using Plots
using SimpleSDMLayers
using Statistics

include(joinpath("..", "lib", "zscores.jl"))

mangal = CSV.read(joinpath("data", "network_data.csv"))

# Remove everything that has a missing latitude, longitude, or bc1
bcdata = dropmissing(mangal, [:latitude, :longitude, :bc1]; disallowmissing = true)

prdata = bcdata[bcdata.predation .> 0, :]
padata = bcdata[bcdata.parasitism .> 0, :]
mudata = bcdata[bcdata.mutualism .> 0, :]

# Transform the bioclim layers
bc = worldclim(1:19; resolution=10.0, bottom=-60.0)
zbc = z.(bc)

geo_dis = similar(first(bc))
env_dis = similar(first(bc))

all_cells = [(b.longitude, b.latitude) for b in eachrow(prdata)]
bc_obs = ones(Float64, (length(bc), length(all_cells)))
for j in 1:length(all_cells)
    try
        this_bc = [zb[all_cells[j]...] for zb in zbc]
        bc_obs[:,j] = this_bc
    catch
    end
end

Base.Threads.@threads for lon in longitudes(geo_dis)
	for lat in latitudes(geo_dis)
		cell = (lon, lat)
        # @info cell
		if !isnothing(geo_dis[cell...])
            # Climatic distance
            cell_bc_values = [zb[cell...] for zb in zbc]
			cell_bc_distance = vec(sum(sqrt.((bc_obs'.-cell_bc_values').^2.0); dims=2))
            env_dis[cell...] = Float32(mean(sort(cell_bc_distance)[1:5]))
            # Haversine distance
			all_dist = [SimpleSDMLayers.haversine(c, cell) for c in all_cells]
            geo_dis[cell...] = Float32(mean(sort(all_dist)[1:5]))
		end
	end
end

heatmap(log1p(env_dis), c=:viridis)
savefig(joinpath("figures", "test1.png"))

heatmap(geo_dis, c=:viridis)
savefig(joinpath("figures", "test2.png"))

error("no")

heatmap(prgdis, c=:Greens, dpi=200, frame=:box)
savefig(joinpath("figures", "geodistance_predation.png"))
xaxis!((-180,80), "Longitude")
yaxis!((-90,90), "Latitude")

heatmap(prbdis, c=:Greens, clim=(0.0,4.5), dpi=200, frame=:box)
savefig(joinpath("figures", "envirodistance_predation.png"))
xaxis!((-180,80), "Longitude")
yaxis!((-90,90), "Latitude")

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
xaxis!((-180,80), "Longitude")
yaxis!((-90,90), "Latitude")

heatmap(pabdis, c=:Oranges, clim=(0,4.5), dpi=200, frame=:box)
savefig(joinpath("figures", "envirodistance_parasitism.png"))
xaxis!((-180,80), "Longitude")
yaxis!((-90,90), "Latitude")

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
xaxis!((-180,80), "Longitude")
yaxis!((-90,90), "Latitude")

heatmap(mubdis, c=:Blues, clim=(0,4.5), dpi=200, frame=:box)
savefig(joinpath("figures", "envirodistance_mutualism.png"))
xaxis!((-180,80), "Longitude")
yaxis!((-90,90), "Latitude")

pr1 = heatmap(prbdis, c=:viridis, clim=(0,4.5), dpi=200, frame=:box, leg=false, size=(900,800), colorbar=:none)
xaxis!(pr1, (-180,80), "Longitude")
yaxis!(pr1, (-90,90), "Latitude")
title!(pr1, "Predation")

pr2 = heatmap(pabdis, c=:viridis, clim=(0,4.5), dpi=200, frame=:box, leg=false, size=(900,800), colorbar=:none)
xaxis!(pr2, (-180,80), "Longitude")
yaxis!(pr2, (-90,90), "Latitude")
title!(pr2, "Parasitism")

pr3 = heatmap(mubdis, c=:viridis, clim=(0,4.5), dpi=200, frame=:box, leg=false, size=(900,800), colorbar=:none)
xaxis!(pr3, (-180,80), "Longitude")
yaxis!(pr3, (-90,90), "Latitude")
title!(pr3, "Mutualism")

plot(
	pr1,
	pr2,
	pr3,
	layout=(3,1), size=(800, 1800)
)

savefig(joinpath("figures", "combined_envirodist_maps.png"))
