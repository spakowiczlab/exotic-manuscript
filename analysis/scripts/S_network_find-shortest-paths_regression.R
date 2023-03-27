library(tidyverse)
library(igraph)

weighted.edges <- readRDS("/fs/ess/PAS1695/projects/exotic/data/network_igraph-data_regression.RDS")

centrality <- betweenness(weighted.edges)

saveRDS(centrality,
        "/fs/ess/PAS1695/projects/exotic/data/network_betweenness-centrality_regression.RDS")

