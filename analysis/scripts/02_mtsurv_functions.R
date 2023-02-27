args = commandArgs(trailingOnly = T)

library(tidyverse)
library(mt.surv)

load("/fs/ess/PAS1695/projects/exotic/data/survquant-inputs.rda")

x <- make.names(sigmics$microbe[args[1]])

if(sigmics$cancer[args[1]] != "All") {
  tcc.modin <- tcc.modin %>%
    filter(TCGA.code == sigmics$cancer[args[1]])
  tcga.modin <- tcga.modin %>%
    filter(cancer == sigmics$cancer[args[1]])
}

tcc.survquant <- survivalByQuantile(x, tcc.modin, tcc.modin) %>%
    mutate(microbe = x, datset = "ORIEN")

tcga.survquant <- survivalByQuantile(x, tcga.modin, tcga.modin) %>%
    mutate(microbe = x, datset = "TCGA")

quantres <- bind_rows(tcc.survquant,tcga.survquant)

write.csv(quantres,
          paste0("/fs/ess/PAS1695/projects/exotic/data/survquant_agree/microbe_",
                 args[1], 
                 ".csv"), 
          row.names = F)

