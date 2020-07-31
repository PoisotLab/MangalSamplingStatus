
function download_shapefile(res)
    @assert res ∈ [50, 100]
    dir = "https://github.com/nvkelso/natural-earth-vector/" * "raw/master/$(res)m_physical"

    fn = "ne_$(res)m_land.shp"
    download("$dir/$fn", joinpath("assets", fn))
    return joinpath("assets", fn)
end

function worldshape(res)
    shp = download_shapefile(res)
    handle = open(shp, "r") do io
        read(io, Shapefile.Handle)
    end
    return handle
end
