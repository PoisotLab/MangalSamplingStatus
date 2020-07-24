using SimpleSDMLayers
using DataFrames
using CSV

network_metadata = DataFrame(CSV.File(joinpath("data", "network_metadata.csv")))

wc_data = worldclim(1:19; resolution=10.0)

network_bioclim = DataFrame()

network_bioclim.id = network_metadata.id
for layer_number in 1:length(wc_data)
   tmp = fill(NaN, size(network_metadata, 1))
   for (rownumber, row) in enumerate(eachrow(network_metadata))
      if !ismissing(row.latitude)
          val = wc_data[layer_number][row.longitude, row.latitude]
          tmp[rownumber] = isnothing(val) ? NaN : val
      end
   end
   network_bioclim[!, Symbol("bc"*string(layer_number))] = tmp
end

CSV.write(joinpath("data", "network_bioclim.csv"), network_bioclim)
