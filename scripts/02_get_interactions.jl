using Mangal
using DataFrames
using CSV
using GeoInterface

network_metadata = CSV.read(joinpath("data", "network_metadata.dat"))

network_interactions = DataFrame()
network_interactions.id = network_metadata.id
network_interactions.nodes = [count(MangalNode, "network_id" => i) for i in network_interactions.id]
network_interactions.links = [count(MangalInteraction, "network_id" => i) for i in network_interactions.id]
network_interactions.mutualism = [count(MangalInteraction, "network_id" => i, "type" => "mutualism") for i in network_interactions.id]
network_interactions.parasitism = [count(MangalInteraction, "network_id" => i, "type" => "parasitism") for i in network_interactions.id]
network_interactions.predation = [count(MangalInteraction, "network_id" => i, "type" => "predation") for i in network_interactions.id]

CSV.write(joinpath("data", "network_interactions.dat"), network_interactions)
