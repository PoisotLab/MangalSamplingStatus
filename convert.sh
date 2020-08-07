#!/bin/bash

convert figures/env-distance-* -append figures/comb-env.png
convert figures/geo-distance-* -append figures/comb-geo.png
convert figures/comb-* +append figures/combined-distances.png
