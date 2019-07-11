module MangalSuppMatGetMetaData

using Mangal
using MangalSuppMat
using SimpleSDMLayers
using DataFrames
using CSV
using GeoInterface

if !("network_metadata.dat" in readdir(pwd()))
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

   CSV.write("network_metadata.dat", network_metadata)
end

end