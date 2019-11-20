using DataFrames
using CSV
using Plots
using Shapefile
using SimpleSDMLayers

include(joinpath("..", "lib", "worldshape.jl"))

mangal = CSV.read(joinpath("data", "network_data.csv"))

# Remove everything that has a missing date
with_date = dropmissing(mangal, :date; disallowmissing = true)
# Sort by date, oldest first
sort!(with_date, [:date])
# Add an index to see the cumulative number of networks
with_date.tick = collect(1:size(with_date, 1))

# And plot
plot(with_date.date, with_date.tick, lab="All networks", c=:black, legend=:topleft)
savefig(joinpath("figures", "increase_over_time.png"))

# Network properties
scatter(with_date.date, with_date.nodes, lab="Nodes", c=:black, legend=:topleft)
scatter!(with_date.date, with_date.links, lab="Interactions", c=:grey)
savefig(joinpath("figures", "properties_over_time.png"))

para = with_date[with_date.parasitism.>0,:]
para.tick = collect(1:size(para, 1))
mutu = with_date[with_date.mutualism.>0,:]
mutu.tick = collect(1:size(mutu, 1))
pred = with_date[with_date.predation.>0,:]
pred.tick = collect(1:size(pred, 1))

plot!(para.date, para.tick, c="#e69f00", lab="Parasitism")
plot!(mutu.date, mutu.tick, c="#56b4e9", lab="Mutualism")
plot!(pred.date, pred.tick, c="#009e73", lab="Predation")

xaxis!("Date of collection")
yaxis!("Number of networks")
savefig(joinpath("figures", "network_growth_over_time.png"))

oknetworks = mangal[mangal.links .> 0, :]

scatter(oknetworks.nodes, oknetworks.links, leg=false, c=:black)
xaxis!(:log, "Number of nodes")
yaxis!(:log, "Number of links")
savefig(joinpath("figures", "links_species_relationship.png"))

world = worldshape(50)
networkplot = plot([0.0], lab="", msw=0.0, ms=0.0, legend=:bottomleft, frame=:box, aspectratio=1)
xaxis!(networkplot, (-180,180), "Longitude")
yaxis!(networkplot, (-90,90), "Latitude")

for p in world.shapes
    sh = Shape([pp.x for pp in p.points], [pp.y for pp in p.points])
    plot!(networkplot, sh, c=:lightgrey, lc=:lightgrey, lab="")
end

okdata = dropmissing(mangal, [:latitude, :longitude]; disallowmissing = true)

para = okdata[okdata.parasitism.>0,:]
mutu = okdata[okdata.mutualism.>0,:]
pred = okdata[okdata.predation.>0,:]

scatter!(networkplot, para[:longitude], para[:latitude], c="#e69f00", lab="Parasitism")
scatter!(networkplot, mutu[:longitude], mutu[:latitude], c="#56b4e9", lab="Mutualism")
scatter!(networkplot, pred[:longitude], pred[:latitude], c="#009e73", lab="Predation")

savefig(joinpath("figures", "map_networks_type.png"))
