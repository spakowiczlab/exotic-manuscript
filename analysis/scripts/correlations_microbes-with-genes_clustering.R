library(tidyverse)
library(data.table)
library(dtplyr)
library(tidyfast)
library(ggdendro)

res.df <- readRDS("/fs/ess/PAS1695/projects/exotic/data/mic-genes_sigsum.RDS")

sig.df.clust <- res.df %>%
  lazy_dt() %>%
  mutate(summary.code = case_when(is.na(heatmap.code) ~ 0,
                                  heatmap.code == "TCGA only" ~ 1,
                                  heatmap.code == "TCC only" ~ 2,
                                  heatmap.code == "disagree" ~ 3,
                                  heatmap.code == "match" ~ 4)) %>%
  select(microbe, Gene, summary.code) %>%
  as.data.table()
rm(res.df)

sig.df.genes <- sig.df.clust %>%
  dt_pivot_wider(names_from = microbe, values_from = summary.code) %>%
  as.data.frame() %>%
  column_to_rownames(var = "Gene") %>%
  dist() %>%
  hclust() %>%
  dendro_data()
heat.geneord <- sig.df.genes$labels$label
saveRDS(heat.geneord, "/fs/ess/PAS1695/projects/exotic/data/mic-genes_geneord.RDS")
rm(sig.df.genes)

sig.df.mic <- sig.df.clust %>%
  dt_pivot_wider(names_from = Gene, values_from = summary.code) %>%
  as.data.frame() %>%
  column_to_rownames(var = "microbe") %>%
  dist() %>%
  hclust() %>%
  dendro_data()
heat.micord <- sig.df.mic$labels$label
saveRDS(heat.micord, "/fs/ess/PAS1695/projects/exotic/data/mic-genes_micord.RDS")