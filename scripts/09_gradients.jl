using DataFrames
using Statistics
using Mangal
import CSV
using StatsPlots
using Plots.PlotMeasures
using Statistics
using EcologicalNetworks

mangal = DataFrame(CSV.File(joinpath("data", "network_post_pca.csv")))

foodwebs = mangal[mangal.predation .> 0, :]
foodwebs = foodwebs[foodwebs.links .< 500, :]

Ns = convert.(UnipartiteNetwork, Mangal.network.(foodwebs.id))

tl = (n) -> mean(collect(values(trophic_level(n))))
v = tl.(Ns)

lin = unipartitemotifs()[:S1]
omn = unipartitemotifs()[:S2]
slf = unipartitemotifs()[:S3]
dir = unipartitemotifs()[:S4]
app = unipartitemotifs()[:S5]

n_lin = [length(find_motif(n, lin)) for n in Ns]
n_omn = [length(find_motif(n, omn)) for n in Ns]
n_slf = [length(find_motif(n, slf)) for n in Ns]
n_dir = [length(find_motif(n, dir)) for n in Ns]
n_app = [length(find_motif(n, app)) for n in Ns]

n_tot = n_lin .+ n_omn .+ n_slf .+ n_dir .+ n_app

v = n_app ./ (n_dir .+ n_app)

scatter(foodwebs.pc1, foodwebs.pc2, marker_z = v, c=:YlGnBu, lab="", frame=:zerolines)

scatter(foodwebs.pc1, v, marker_z = v, c=:YlGnBu, frame=:zerolines)
