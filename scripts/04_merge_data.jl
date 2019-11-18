using DataFrames
using CSV


network_metadata = CSV.read(joinpath("data", "network_metadata.dat"))
network_interactions = CSV.read(joinpath("data", "network_interactions.dat"))
network_bioclim = CSV.read(joinpath("data", "network_bioclim.dat"))

network_data = join(join(network_metadata, network_interactions, on=:id), network_bioclim, on=:id)

CSV.write(joinpath("data", "network_data.dat"), network_data)
