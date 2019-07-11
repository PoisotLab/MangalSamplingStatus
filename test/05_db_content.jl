module MangalSuppMatGetData

using DataFrames
using CSV
using Plots

mangal = CSV.read("network_data.dat")

# Remove everything that has a missing date
with_date = dropmissing(mangal, :date; disallowmissing = true)
# Sort by date, oldest first
sort!(with_date, [:date])
# Add an index to see the cumulative number of networks
with_date.tick = collect(1:size(with_date, 1))

# And plot 
plot(with_date.date, with_date.tick, leg=false, c=:black)
xaxis!("Date of collection")
yaxis!("Number of networks")
savefig(joinpath(@__DIR__, "..", "figures", "figure_01_a.png"))

oknetworks = mangal[mangal.links .> 0, :]

scatter(oknetworks.nodes, oknetworks.links, leg=false, c=:black)
xaxis!(:log, "Number of nodes")
yaxis!(:log, "Number of links")
savefig(joinpath(@__DIR__, "..", "figures", "figure_01_b.png"))

end
