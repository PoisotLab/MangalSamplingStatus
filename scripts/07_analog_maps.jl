using DataFrames
using CSV
using Plots
using Plots.PlotMeasures
using SimpleSDMLayers
using Statistics

include(joinpath(pwd(), "lib", "zscores.jl"))

cmap_start = "#f0f0f0"
cmap_para = [cmap_start, "#e69f00"]
cmap_mutu = [cmap_start, "#56b4e9"]
cmap_pred = [cmap_start, "#009e73"]

mangal = CSV.read(joinpath("data", "network_data.csv"))

# Remove everything that has a missing latitude, longitude, or bc1
bcdata = dropmissing(mangal, [:latitude, :longitude, :bc1]; disallowmissing = true)

prdata = bcdata[bcdata.predation .> 0, :]
padata = bcdata[bcdata.parasitism .> 0, :]
mudata = bcdata[bcdata.mutualism .> 0, :]

# Transform the bioclim layers
bc = worldclim(1:19; resolution = 10.0, bottom = -60.0)

zbc = z.(bc)

function distmap(intdata; k = 3)
    geo_dis = similar(first(bc))
    env_dis = similar(first(bc))
    all_cells = [(b.longitude, b.latitude) for b in eachrow(intdata)]
    bc_obs = ones(Float64, (length(bc), length(all_cells)))
    for j = 1:length(all_cells)
        try
            this_bc = [zb[all_cells[j]...] for zb in zbc]
            bc_obs[:, j] = this_bc
        catch
        end
    end
    Base.Threads.@threads for lon in longitudes(geo_dis)
        for lat in latitudes(geo_dis)
            cell = (lon, lat)
            if !isnothing(geo_dis[cell...])
                # Climatic distance
                cell_bc_values = [zb[cell...] for zb in zbc]
                cell_bc_distance =
                    vec(sum(sqrt.((bc_obs' .- cell_bc_values') .^ 2.0); dims = 2))
                env_dis[cell...] = Float32(mean(sort(cell_bc_distance)[1:k]))
                # Haversine distance
                all_dist = [SimpleSDMLayers.haversine(c, cell) for c in all_cells]
                geo_dis[cell...] = Float32(mean(sort(all_dist)[1:k]))
            end
        end
    end
    return (geo_dis, env_dis)
end

geo_par, env_par = distmap(padata)
geo_mut, env_mut = distmap(mudata)
geo_prd, env_prd = distmap(prdata)

p1 = heatmap(
    log1p(env_par),
    c = :GnBu,
    clim = (0, 4.5),
    dpi = 200,
    margin = 10mm,
    foreground_color_legend = nothing,
    frame = :box,
    top_margin = 1mm,
    size=(500,250),
    title="Parasitism"
);
p2 = heatmap(
    log1p(env_mut),
    c = :GnBu,
    clim = (0, 4.5),
    dpi = 200,
    margin = 10mm,
    foreground_color_legend = nothing,
    frame = :box,
    top_margin = 1mm,
    size=(500,250),
    title="Mutualism"
);
p3 = heatmap(
    log1p(env_prd),
    c = :GnBu,
    clim = (0, 4.5),
    dpi = 200,
    margin = 10mm,
    foreground_color_legend = nothing,
    frame = :box,
    top_margin = 1mm,
    size=(500,250),
    title="Predation"
);
savefig(p1, joinpath("figures", "env-distance-para.png"))
savefig(p2, joinpath("figures", "env-distance-mutu.png"))
savefig(p3, joinpath("figures", "env-distance-pred.png"))

p1 = heatmap(
    geo_par,
    c = :YlGn,
    clim = (0, 5000),
    dpi = 200,
    margin = 5mm,
    foreground_color_legend = nothing,
    frame = :box,
    top_margin = 1mm,
    size=(500,250),
    title="Parasitism"
);
savefig(p1, joinpath("figures", "geo-distance-para.png"))

p2 = heatmap(
    geo_mut,
    c = :YlGn,
    clim = (0, 5000),
    dpi = 200,
    margin = 10mm,
    foreground_color_legend = nothing,
    frame = :box,
    top_margin = 1mm,
    size=(500,250),
    title="Mutualism"
);
p3 = heatmap(
    geo_prd,
    c = :YlGn,
    clim = (0, 5000),
    dpi = 200,
    margin = 10mm,
    foreground_color_legend = nothing,
    frame = :box,
    top_margin = 1mm,
    size=(500,250),
    title="Predation"
);
savefig(p2, joinpath("figures", "geo-distance-mutu.png"))
savefig(p3, joinpath("figures", "geo-distance-pred.png"))
