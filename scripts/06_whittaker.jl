using DataFrames
using CSV
using Plots
using Plots.PlotMeasures
using SimpleSDMLayers

mangal = DataFrame(CSV.File(joinpath("data", "network_data.csv")))

# Remove everything that has a missing date
whittaker = dropmissing(mangal, [:bc1, :bc12]; disallowmissing = true)

para = whittaker[whittaker.parasitism .> 0, :]
mutu = whittaker[whittaker.mutualism .> 0, :]
pred = whittaker[whittaker.predation .> 0, :]

n_para = size(para)[1]
n_mutu = size(mutu)[1]
n_pred = size(pred)[1]

b1 = worldclim(1; bottom = -60.0)
b12 = broadcast(n -> n/10.0, worldclim(12; bottom = -60.0))

# And plot
histogram2d(
    b12,
    b1,
    frame = :box,
    dpi = 200,
    margin = 10mm,
    foreground_color_legend = nothing,
    legend = :outertopright,
    colorbar = false,
    lab = "",
    c = [:lightgrey, :black],
    bins = 50
)
scatter!(para.bc12 ./ 10.0, para.bc1, lab = "Parasitism", c = "#e69f00", ms = 3, msw = 0.0)
scatter!(mutu.bc12 ./ 10.0, mutu.bc1, lab = "Mutualism", c = "#56b4e9", ms = 3, msw = 0.0)
scatter!(pred.bc12 ./ 10.0, pred.bc1, lab = "Predation", c = "#009e73", ms = 3, msw = 0.0)
xaxis!("Annual precipitation", (0.0, 800.0))
yaxis!("Average temperature", :flip, [-20.0, 30.0])
savefig(joinpath("figures", "networks_by_biomes.png"))
# savefig(joinpath("figures", "networks_by_biomes.pdf"))
