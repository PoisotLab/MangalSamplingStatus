using DataFrames
using CSV
using StatsPlots
using Plots.PlotMeasures
using Statistics
using MultivariateStats

range(x::Vector{T}) where {T <: Number} = (x .- mean(x)) ./ std(x)

mangal = DataFrame(CSV.File(joinpath("data", "network_data.csv")))
bcdata = bcdata[.!(isnan.(bcdata.bc1)), :]
bc_webs = convert(Matrix{Float64}, bcdata[:, r"bc"])
bc_std = rotl90(mapslices(range, bc_webs; dims=1))

M = fit(PCA, bc_std)
P = MultivariateStats.transform(M, bc_std)
scatter(P[1,:], P[2,:], lab="", c=:grey, msw=0.0, ms=2, frame=:origin)

bcdata.pc1 = P[1, :]
bcdata.pc2 = P[2, :]
bcdata.pc3 = P[3, :]
bcdata.pc4 = P[4, :]
bcdata.D = vec(sum(sqrt.(P .^ 2.0); dims = 1))

CSV.write(joinpath("data", "network_post_pca.csv"), bcdata)

para = bcdata[bcdata.parasitism .> 0, :]
mutu = bcdata[bcdata.mutualism .> 0, :]
pred = bcdata[bcdata.predation .> 0, :]

scatter(
    para.pc1,
    para.pc2,
    frame = :origin,
    c = "#e69f00",
    lab = "Parasitism",
    legend = :outertopright,
    aspectratio = 1,
    ms = 3,
    msw = 0.0,
    dpi = 200,
    xlabel = "Position on PC1",
    ylabel = "Position on PC2",
    margin = 10mm,
)
scatter!(mutu.pc1, mutu.pc2, c = "#56b4e9", lab = "Mutualism", ms = 3, msw = 0.0)
scatter!(pred.pc1, pred.pc2, c = "#009e73", lab = "Predation", ms = 3, msw = 0.0)
savefig(joinpath("figures", "networks_pca.png"))
# savefig(joinpath("figures", "networks_pca.pdf"))

histogram(
    para.pc1,
    c = "#e69f00",
    lab = "Parasitism",
    dpi = 200,
    frame = :box,
    xlabel = "Position on PC1",
    margin = 10mm,
    left_margin = 20mm,
    normalize = :probability,
    legend = :outertopright,
    alpha = 0.5,
    lw = 0.0,
)
histogram!(
    mutu.pc1,
    c = "#56b4e9",
    lab = "Mutualism",
    normalize = :probability,
    alpha = 0.5,
    lw = 0.0,
)
histogram!(
    pred.pc1,
    c = "#009e73",
    lab = "Predation",
    normalize = :probability,
    alpha = 0.5,
    lw = 0.0,
)
xaxis!((-10, 10))
yaxis!((0, 0.75))
savefig(joinpath("figures", "position_on_pc1.png"))
# savefig(joinpath("figures", "position_on_pc1.pdf"))

m = maximum(bcdata.D)

histogram(
    para.D,
    c = "#e69f00",
    lab = "Parasitism",
    dpi = 200,
	frame = :box,
	legend = :outertopright,
    margin = 10mm,
    left_margin = 20mm,
    normalize = :probability,
    alpha = 0.5, lw = 0.0
)
histogram!(mutu.D, c = "#56b4e9", lab = "Mutualism", normalize=:probability, alpha=0.5, lw=0.0)
histogram!(pred.D, c = "#009e73", lab = "Predation", normalize=:probability, alpha=0.5, lw=0.0)
xaxis!((0, 25), "Distance (unitless) to centroid")
yaxis!((0, 0.6))
savefig(joinpath("figures", "distance_to_centroid.png"))
# savefig(joinpath("figures", "distance_to_centroid.pdf"))
