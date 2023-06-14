library(tidyverse)

# loadTCCCorrs <- function(fpath){
#   tmp <- read.csv(fpath, stringsAsFactors = F)
#   tmp.form <- tmp %>% 
#     filter(datset == "TCC" &
#              term != "(Intercept)" &
#              !grepl("TCGA", term))
#   
#   return(tmp.form)
# }
# 
# 
# resdir <- "/fs/ess/PAS1695/projects/exotic/data/regressions_mic-gene"
# res.files <- list.files(resdir, full.names = T)
# 
# TCC.dat <- lapply(res.files, loadTCCCorrs) %>%
#   bind_rows() %>%
#   mutate(padj = p.adjust(p.value, method = "fdr"))
# 
# saveRDS(TCC.dat, "/fs/ess/PAS1695/projects/exotic/data/regressions_mic-gene_TCC.RDS")

network.in <- readRDS("/fs/ess/PAS1695/projects/exotic/data/network_TCC-reg-in.RDS")
network.adj <- network.in %>%
  mutate(padj = p.adjust(p.value, method = "fdr"))
saveRDS(network.adj, "../data/network_TCC-reg-in_adjusted.RDS")


degree.cent <- read.csv("../tables/S2_network_microbe_degree-centrality.csv")
survmics <- readRDS("../data/survival_concordance-table.RDS") %>%
  filter(agree.code == T)

checkdeg <- degree.cent %>%
  filter(microbe %in% survmics$microbe)

topdegs <- degree.cent %>%
  filter(n <= 1000) %>%
  select(microbe) %>%
  inner_join(network.adj)

write.csv(topdegs, "../tables/sup_network_top-degcent-mics.csv", row.names = F)
