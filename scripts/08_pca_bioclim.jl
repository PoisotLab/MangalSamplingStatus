using DataFrames
using CSV
using StatsPlots
using Statistics
using MultivariateStats


pyplot()

mangal = CSV.read(joinpath("data", "network_data.csv"))

bcdata = dropmissing(mangal, [:bc1]; disallowmissing = true)
bcdata = bcdata[.!isnan.(bcdata.bc1), :]

bc_colnames = Symbol.("bc".*string.(1:19))
bc_webs = convert(Matrix, bcdata[:,bc_colnames])

@info size(bc_webs')

M = fit(PCA, bc_webs')
P = transform(M, bc_webs')

bcdata.pc1 = (P[1,:].-mean(P[1,:]))./std(P[1,:])
bcdata.pc2 = (P[2,:].-mean(P[2,:]))./std(P[2,:])
bcdata.D = vec(sum(sqrt.(P.^2.0); dims=1))

para = bcdata[bcdata.parasitism.>0,:]
mutu = bcdata[bcdata.mutualism.>0,:]
pred = bcdata[bcdata.predation.>0,:]

scatter(para.pc1, para.pc2, frame=:origin, c="#e69f00", lab="Parasitism", legend=:bottomleft, dpi=200, xlabel="Position on PC1", ylabel="Position on PC2")
scatter!(mutu.pc1, mutu.pc2, c="#56b4e9", lab="Mutualism")
scatter!(pred.pc1, pred.pc2, c="#009e73", lab="Predation")
savefig(joinpath("figures", "networks_pca.png"))
# savefig(joinpath("figures", "networks_pca.pdf"))

density(para.pc1, c="#e69f00", lab="Parasitism", dpi=200, frame=:box, xlabel="Position on PC1")
density!(mutu.pc1, c="#56b4e9", lab="Mutualism")
density!(pred.pc1, c="#009e73", lab="Predation")
savefig(joinpath("figures", "position_on_pc1.png"))
# savefig(joinpath("figures", "position_on_pc1.pdf"))

m = maximum(bcdata.D)

density(para.D./m, c="#e69f00", lab="Parasitism", dpi=200, frame=:box)
density!(mutu.D./m, c="#56b4e9", lab="Mutualism")
density!(pred.D./m, c="#009e73", lab="Predation")
xaxis!((0,1), "Ranged distance to centroid")
savefig(joinpath("figures", "distance_to_centroid.png"))
# savefig(joinpath("figures", "distance_to_centroid.pdf"))
