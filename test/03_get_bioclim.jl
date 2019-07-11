module MangalSuppMatGetBioclim

using Mangal
using MangalSuppMat
using SimpleSDMLayers
using DataFrames
using CSV
using GeoInterface

if !("network_bioclim.dat" in readdir(pwd()))

   network_metadata = CSV.read("network_metadata.dat")

   wc_data = worldclim(1:19; resolution="5")

   network_bioclim = DataFrame()

   network_bioclim.id = network_metadata.id
   for layer_number in 1:length(wc_data)
      tmp = fill(NaN, size(network_metadata, 1))
      for (rownumber, row) in enumerate(eachrow(network_metadata))
         if !ismissing(row.latitude)
            tmp[rownumber] = wc_data[layer_number][row.longitude, row.latitude]
         end
      end
      network_bioclim[Symbol("bc"*string(layer_number))] = tmp
   end

   CSV.write("network_bioclim.dat", network_bioclim)
end

end
