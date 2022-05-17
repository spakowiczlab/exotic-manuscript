library(tidyverse)
library(igraph)

all.nodes.combos <- readRDS("/fs/ess/PAS1695/projects/exotic/data/network_all-node-combos.RDS")
weighted.edges <- readRDS("/fs/ess/PAS1695/projects/exotic/data/network_igraph-data.RDS")

grabShortPaths <- function(n){
  tmppath <- shortest_paths(weighted.edges, 
                            from = all.nodes.combos[1,n],
                            to = all.nodes.combos[2,n]) 
  tmp.return <- gsub("vpath.", "", names(unlist(tmppath)))
  return(tmp.return)
}

all.paths <- lapply(1:ncol(all.nodes.combos), grabShortPaths)

saveRDS(all.paths,
        "/fs/ess/PAS1695/projects/exotic/data/network_all-shortest-paths.RDS")

