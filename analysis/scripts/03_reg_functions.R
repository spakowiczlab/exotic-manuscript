args = commandArgs(trailingOnly = T)

library(tidyverse)
library(broom)
library(rlist)

# Load data

tcc.modin <- readRDS("/fs/ess/PAS1695/projects/exotic/data/mic-genes_TCC.RDS")
tcga.modin <- readRDS("/fs/ess/PAS1695/projects/exotic/data/mic-genes_TCGA.RDS")
microbes <- readRDS("/fs/ess/PAS1695/projects/exotic/data/microbe-names.RDS")
genes.ls <- readRDS("/fs/ess/PAS1695/projects/exotic/data/gene-lists.RDS")

# Define function

capture.models.cancer <- function(modin, d){
  mods.list <- lapply(genes, function(x) 
    lapply(microbes, function(y)
    try({glm(as.formula(paste0("`", y, "` ~ `", x, "`+ TCGA.code")), 
             family = "Gamma",
             data = modin) %>%
      tidy() %>%
      mutate(gene = x,
             microbe = y,
             datset = d)}))
  )
  
  mods.list.clean <- lapply(mods.list, function(y) list.clean(y, function(x) is.character(x)))
  mods.df <- bind_rows(mods.list.clean)
  return(mods.df)
}

# Run for select genes
genes <- genes.ls[[args[1]]]
tcc.res <- capture.models.cancer(tcc.modin, "TCC")
tcga.res <- capture.models.cancer(tcga.modin, "TCGA")

all.df <- bind_rows(tcc.res, tcga.res)

write.csv(all.df, 
          paste0("/fs/ess/PAS1695/projects/exotic/data/regressions_mic-gene/controlled_",
                         args[1], ".csv"), row.names = F)