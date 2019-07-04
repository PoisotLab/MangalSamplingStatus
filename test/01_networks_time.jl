module MangalSuppMatGetData

using DataFrames
using CSV
using Plots

mangal = CSV.read("networkinfo.dat")

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
savefig(joinpath(@__DIR__, "..", "figures", "figure_01.pdf"))

end
