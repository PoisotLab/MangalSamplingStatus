
function download_shapefile(res)
   @assert res ∈ [50, 100]
   dir = "https://github.com/nvkelso/natural-earth-vector/" *
   "raw/master/$(res)m_physical/"

   fn = "ne_$(res)m_land.shp"
   run(`wget $dir/$fn -P ./assets/`)
end

function worldshape(res)
   download_shapefile(res)
   pat = joinpath("assets", "ne_$(res)m_land.shp")
   handle = open(pat, "r") do io
      read(io, Shapefile.Handle)
   end
   return handle
end
