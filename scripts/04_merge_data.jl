using DataFrames
using CSV

network_metadata = DataFrame(CSV.File(joinpath("data", "network_metadata.csv")))
network_interactions = DataFrame(CSV.File(joinpath("data", "network_interactions.csv")))
network_bioclim = DataFrame(CSV.File(joinpath("data", "network_bioclim.csv")))

network_data = join(join(network_metadata, network_interactions, on=:id), network_bioclim, on=:id)

CSV.write(joinpath("data", "network_data.csv"), network_data)
