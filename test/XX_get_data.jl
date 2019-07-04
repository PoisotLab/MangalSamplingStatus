module MangalSuppMatGetData

using Mangal
using SimpleSDMLayers
using DataFrames
using CSV
using GeoInterface

const number_of_networks = count(MangalNetwork)

page = 0
all_networks = networks()
while length(all_networks) < number_of_networks
   global page = page + 1
   @info "page $(page)"
   append!(all_networks,
           networks("page" => page)
          )
end

# Step 1 -- get the metadata

network_metadata = DataFrame()
network_metadata.id = [n.id for n in all_networks]
network_metadata.name = [n.name for n in all_networks]
network_metadata.date = [n.date for n in all_networks]

function get_coordinates(n::MangalNetwork; dims::Int64=1)
   if ismissing(n.position)
      return missing
   end
   if !(typeof(n.position) <: GeoInterface.Point)
      return missing
   end
   return coordinates(n.position)[dims]
end
longitude(n::MangalNetwork) = get_coordinates(n; dims=1)
latitude(n::MangalNetwork) = get_coordinates(n; dims=2)

network_metadata.latitude = latitude.(all_networks)
network_metadata.longitude = longitude.(all_networks)

# Step 2 -- get the interactions

network_interactions = DataFrame()
network_interactions.id = network_metadata.id
network_interactions.nodes = [count(MangalNode, "network_id" => i) for i in network_interactions.id]
network_interactions.links = [count(MangalInteraction, "network_id" => i) for i in network_interactions.id]
network_interactions.mutualism = [count(MangalInteraction, "network_id" => i, "type" => "mutualism") for i in network_interactions.id]
network_interactions.parasitism = [count(MangalInteraction, "network_id" => i, "type" => "parasitism") for i in network_interactions.id]
network_interactions.predation = [count(MangalInteraction, "network_id" => i, "type" => "predation") for i in network_interactions.id]
network_interactions.herbivory = [count(MangalInteraction, "network_id" => i, "type" => "herbivory") for i in network_interactions.id]

# Step 3 - get the bioclim data

bc = worldclim(1:19; resolution="10")

network_bioclim = DataFrame()

import Base: getindex
function getindex(s::SimpleSDMLayer, n::MangalNetwork)
   lat, lon = latitude(n), longitude(n)
   if ismissing(lat)
      return missing
   end
   if ismissing(lon)
      return missing
   end
   bcval = s[lon, lat]
   if isnan(bcval)
      return missing
   end
   return bcval
end

network_bioclim.id = [n.id for n in all_networks]
for b in 1:19
   network_bioclim[Symbol("bc"*string(b))] = [bc[b][n] for n in all_networks]
end

network_data = join(join(network_metadata, network_interactions, on=:id), network_bioclim, on=:id)

CSV.write("networkinfo.dat", network_data)

end
