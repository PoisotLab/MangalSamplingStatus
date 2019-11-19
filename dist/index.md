# Overview

This website is automatically generated from the [`mangal.io`](mangal.io)
database. It gives an overview, updated weekly, of the completeness of sampling.
The figures and data are generated through the use of github actions, and
reflect the most up to date state of the analysis. The workflow file downloads
the most recent version of the data, of the packages used for the analysis, and
of their dependencies, then generates the data frames and figures, and pushes
everything to this page.

# Project organization

The repository only stores the scripts (in `scripts`) and a few helper functions
(in `lib`), as well as the workflow. Everything else gets generated weekly. The
`gh-pages` branch has a copy of the figures (in `figures`) and data (in `data`).
All of the website material are in the `dist` folder, which is written in during
the build step, although the results are not committed to the `master` branch.

# Data files

| Output                     | Script                   | Description                                                          |
| -------------------------- | ------------------------ | -------------------------------------------------------------------- |
| `network_metadata.dat`     | `01_get_metadata.jl`     | id, name, latitude, and longitude                                    |
| `network_interactions.dat` | `02_get_interactions.jl` | id, number of nodes, links, predation, parasitism, mutualism         |
| `network_bioclim.dat`      | `03_get_bioclim.jl`      | id, one column for each bioclim variable                             |
| `network_data.dat`         | `04_merge_data.jl`       | merge of the three previous steps (main table used for the analysis) |

# Figures
