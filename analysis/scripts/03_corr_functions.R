args = commandArgs(trailingOnly = T)

library(tidyverse)
library(broom)

# Load data

tcc.modin <- readRDS("/fs/ess/PAS1695/projects/exotic/data/mic-genes_TCC.RDS")
tcga.modin <- readRDS("/fs/ess/PAS1695/projects/exotic/data/mic-genes_TCGA.RDS")
microbes <- readRDS("/fs/ess/PAS1695/projects/exotic/data/microbe-names.RDS")
genes.ls <- readRDS("/fs/ess/PAS1695/projects/exotic/data/gene-lists.RDS")

# Define function

correlate_mics_genes <- function(mics, genes, data, datalab){
  cor.res <- lapply(mics, function(m) lapply(genes, function(i)
    try(cor.test(data[[m]], data[[i]],
                 method = "spearman") %>%
          tidy() %>%
          mutate(Gene = i, microbe = m, datset = datalab))))
  
  
  test <- lapply(cor.res, function(x) bind_rows(x))
  cor.df <- bind_rows(test)
  return(cor.df)
}

# Run for select genes
genes.small <- genes.ls[[args[1]]]
tcc.res <- correlate_mics_genes(microbes, genes.small, tcc.modin, "TCC")
tcga.res <- correlate_mics_genes(microbes, genes.small, tcga.modin, "TCGA")

all.df <- bind_rows(tcc.res, tcga.res)

write.csv(all.df, paste0("/fs/ess/PAS1695/projects/exotic/data/correlations_mic-gene_",
                         args[1], ".csv"), row.names = F)