module MangalSuppMatAnalogMaps

using MangalSuppMat

using DataFrames
using CSV
using StatsPlots
using Statistics
using MultivariateStats

mangal = CSV.read("network_data.dat")

bcdata = dropmissing(mangal, [:bc1]; disallowmissing = true)
bcdata = bcdata[.!isnan.(bcdata.bc1), :]

bc_colnames = Symbol.("bc".*string.(1:19))
bc_webs = convert(Matrix, bcdata[:,bc_colnames])

@info size(bc_webs')

M = fit(PCA, bc_webs')
P = transform(M, bc_webs')

bcdata.pc1 = (P[1,:].-mean(P[1,:]))./std(P[1,:])
bcdata.D = vec(sum(sqrt.(P.^2.0); dims=1))

para = bcdata[bcdata.parasitism.>0,:]
mutu = bcdata[bcdata.mutualism.>0,:]
pred = bcdata[bcdata.predation.>0,:]

density(para.pc1)
density!(mutu.pc1)
density!(pred.pc1)
xaxis!("Position on PC1")
savefig(joinpath(@__DIR__, "..", "figures", "figure_05_a.png"))

m = maximum(bcdata.D)

density(para.D./m, c="#e69f00")
density!(mutu.D./m, c="#56b4e9")
density!(pred.D./m, c="#009e73")
xaxis!("Ranged distance to centroid")
savefig(joinpath(@__DIR__, "..", "figures", "figure_05_b.png"))

end
