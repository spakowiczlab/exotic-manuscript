args = commandArgs(trailingOnly = T)

library(tidyverse)
library(broom)
library(rlist)

load("/fs/ess/PAS1695/projects/exotic/data/corr-inputs_mic-buffa-random.rda")

correlate_mics_clin <- function(mics, scores, data, datalab){
  cor.res <- lapply(mics, function(m) lapply(scores, function(i)
    try(cor.test(data[[m]], data[[i]],
                 method = "spearman") %>%
          tidy() %>%
          mutate(score = i, microbe = m, datset = datalab))) %>%
      list.clean(., is.character))
  
  
  test <- lapply(cor.res, function(x) bind_rows(x))
  cor.df <- bind_rows(test)
  return(cor.df)
}

snames <- paste0("seed", args[1])

tcc.res.r <- correlate_mics_clin(microbes, snames, tcc.modin.r, "ORIEN") %>%
  mutate(padj = p.adjust(p.value, method = "fdr"))
tcga.res.r <- correlate_mics_clin(microbes, snames, tcga.modin.r, "TCGA") %>%
  mutate(padj = p.adjust(p.value, method = "fdr"))

tcc.cancers <- unique(tcc.modin.r$TCGA.code)
tcga.cancers <- unique(tcga.modin.r$cancer)

tcc.cph.cancer.r <- lapply(tcc.cancers, function(y)
  correlate_mics_clin(microbes, snames,
                      filter(tcc.modin.r,
                             TCGA.code == y),
                      y))

tcga.cph.cancer.r <- lapply(tcga.cancers, function(y) 
  try(correlate_mics_clin(microbes, snames,
                          filter(tcga.modin.r,
                                 cancer == y),
                          y)))

tcc.cancer.form.r <- bind_rows(tcc.cph.cancer.r) %>%
  mutate(cancer = datset,
         datset = "TCC",
         padj = p.adjust(p.value, method = "fdr")) 
tcga.cancer.form.r <- bind_rows(tcga.cph.cancer.r) %>%
  mutate(cancer = datset,
         datset = "TCGA",
         padj = p.adjust(p.value, method = "fdr")) 

tcc.res <- tcc.res.r %>%
  mutate(cancer = "All") %>%
  bind_rows(tcc.cancer.form.r)

tcga.res <- tcga.res.r %>%
  mutate(cancer = "All") %>%
  bind_rows(tcga.cancer.form.r)

corr.res <- bind_rows(tcc.res, tcga.res)

write.csv(corr.res,
          paste0("/fs/ess/PAS1695/projects/exotic/data/correlations_mic-buffa/seed_",
                 args[1], 
                 ".csv"), 
          row.names = F)