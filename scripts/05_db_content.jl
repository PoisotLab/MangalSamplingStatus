using Dates
using DataFrames
using CSV
using StatsPlots
using Plots.PlotMeasures
using Shapefile
using SimpleSDMLayers

include(joinpath(pwd(), "lib", "worldshape.jl"))

mangal = DataFrame(CSV.File(joinpath("data", "network_data.csv")))

# Remove everything that has a missing date
with_date = dropmissing(mangal, :date; disallowmissing = true)
# Sort by date, oldest first
sort!(with_date, [:date])
# Add an index to see the cumulative number of networks
with_date.tick = collect(1:size(with_date, 1))

# Number of nodes over time
date_labels = DateTime(1900):Dates.Year(10):DateTime(2010)
histogram2d(
    with_date.date,
    log10.(with_date.nodes),
    frame = :box,
    c = :cividis,
    clim = (0, 50),
    xticks = (date_labels, Dates.year.(date_labels)),
    foreground_color_legend = nothing,
    xrotation = 45,
    margin = 10mm,
    bins = 50,
    dpi = 200,
)
xaxis!("Date of collection")
yaxis!((1, 3.5), "Number of nodes (log₁₀)")
savefig(joinpath("figures", "properties_over_time.png"))

# And plot
plot(
    with_date.date,
    with_date.tick,
    xticks = (date_labels, Dates.year.(date_labels)),
    lab = "",
    c = :black,
    legend = :outertopright,
    foreground_color_legend = nothing,
    frame = :box,
    dpi = 200,
    xrotation = 45,
    margin = 10mm,
)
xaxis!("Date of sampling")
yaxis!((1, 1400), "Cumulative number of networks")
para = with_date[with_date.parasitism .> 0, :]
para.tick = collect(1:size(para, 1))
mutu = with_date[with_date.mutualism .> 0, :]
mutu.tick = collect(1:size(mutu, 1))
pred = with_date[with_date.predation .> 0, :]
pred.tick = collect(1:size(pred, 1))
plot!(para.date, para.tick, c = "#e69f00", lab = "Parasitism")
plot!(mutu.date, mutu.tick, c = "#56b4e9", lab = "Mutualism")
plot!(pred.date, pred.tick, c = "#009e73", lab = "Predation")
savefig(joinpath("figures", "network_growth_over_time.png"))

oknetworks = mangal[mangal.links .> 0, :]

scatter(
    oknetworks.nodes,
    oknetworks.links,
    leg = false,
    c = :black,
    msw = 0.0,
    alpha = 0.5,
    dpi = 200,
    margin = 10mm,
    frame = :box,
)
xaxis!(:log, "Number of nodes")
yaxis!(:log, "Number of links")
savefig(joinpath("figures", "links_species_relationship.png"))

world = worldshape(50)

networkplot = plot(
    [0.0],
    lab = "",
    msw = 0.0,
    ms = 0.0,
    legend = :outertopright,
    frame = :box,
    aspectratio = 1,
    dpi = 200,
    margin = 10mm,
    foreground_color_legend = nothing,
)
xaxis!(networkplot, (-180, 180), "Longitude")
yaxis!(networkplot, (-90, 90), "Latitude")

for p in world.shapes
    sh = Shape([pp.x for pp in p.points], [pp.y for pp in p.points])
    plot!(networkplot, sh, c = :lightgrey, lc = :lightgrey, lab = "")
end

okdata = dropmissing(mangal, [:latitude, :longitude]; disallowmissing = true)

para = okdata[okdata.parasitism .> 0, :]
mutu = okdata[okdata.mutualism .> 0, :]
pred = okdata[okdata.predation .> 0, :]

scatter!(
    networkplot,
    para[!, :longitude],
    para[!, :latitude],
    c = "#e69f00",
    lab = "Parasitism",
    msw = 0.0,
    ms = 3,
)
scatter!(
    networkplot,
    mutu[!, :longitude],
    mutu[!, :latitude],
    c = "#56b4e9",
    lab = "Mutualism",
    msw = 0.0,
    ms = 3,
)
scatter!(
    networkplot,
    pred[!, :longitude],
    pred[!, :latitude],
    c = "#009e73",
    lab = "Predation",
    msw = 0.0,
    ms = 3,
)

savefig(joinpath("figures", "map_networks_type.png"))
# savefig(joinpath("figures", "map_networks_type.pdf"))
