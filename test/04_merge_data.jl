module MangalSuppMatMergeData

using DataFrames
using CSV

if !("network_data.dat" in readdir(pwd()))
   network_metadata = CSV.read("network_metadata.dat")
   network_interactions = CSV.read("network_interactions.dat")
   network_bioclim = CSV.read("network_bioclim.dat")

   network_data = join(join(network_metadata, network_interactions, on=:id), network_bioclim, on=:id)

   CSV.write("network_data.dat", network_data)
end

end
