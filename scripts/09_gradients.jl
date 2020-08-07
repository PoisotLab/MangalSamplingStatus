using DataFrames
using Mangal
import CSV
using StatsPlots
using Plots.PlotMeasures
using Statistics
using EcologicalNetworks

mangal = DataFrame(CSV.File(joinpath("data", "network_post_pca.csv")))

mutu = mangal[mangal.mutualism .> 0, :]
mutu = mutu[mutu.links .< 500, :]

Ns = convert.(UnipartiteNetwork, Mangal.network.(mutu.id))

Bs = convert.(BipartiteNetwork, Ns)

scatter(mutu.pc1, connectance.(Bs))
savefig(joinpath("figures", "gradient_connectance.png"))

scatter(mutu.pc1, η.(Bs))
savefig(joinpath("figures", "gradient_nestedness.png"))

scatter(mutu.bc1, connectance.(Bs))
savefig(joinpath("figures", "temperature_connectance.png"))

scatter(mutu.bc1, η.(Bs))
savefig(joinpath("figures", "temperature_nestedness.png"))
