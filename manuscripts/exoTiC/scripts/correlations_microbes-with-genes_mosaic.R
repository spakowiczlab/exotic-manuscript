library(tidyverse)
library(data.table)
library(dtplyr)
library(tidyfast)
library(ggmosaic)

loadSummarizeCorrs <- function(fpath){
  tmp <- read.csv(fpath, stringsAsFactors = F)
  tmp.form <- lazy_dt(tmp) %>% 
    mutate(sig = ifelse(is.na(p.value), F, ifelse(p.value < 0.05, T, F)),
           direct = ifelse(estimate < 0, "negative", "positive"),
           sigdir = paste(sig, direct)) %>%
    select(sigdir, microbe, Gene, datset) %>%
    as.data.table() %>%
    dt_pivot_wider(names_from = datset, values_from = sigdir) %>%
    dt_separate(col = TCC, into = c("TCC.sig", "TCC.dir"), sep = " ") %>%
    dt_separate(col = TCGA, into = c("TCGA.sig", "TCGA.dir"), sep = " ") %>%
    lazy_dt() %>%
    mutate(sig.sum = case_when(TCC.sig == T & TCGA.sig == T ~ "Both",
                               xor(TCC.sig == T, TCGA.sig == T) ~ "One",
                               TCC.sig == F & TCGA.sig == F ~ "Neither"),
           dir.agree = ifelse(TCC.dir == TCGA.dir, "Agree", "Disagree"),
           heatmap.code = case_when(TCC.sig == T & TCGA.sig == T & 
                                      TCC.dir == TCGA.dir ~ "match",
                                    TCC.sig == T & TCGA.sig == T & 
                                      TCC.dir != TCGA.dir ~ "disagree",
                                    TCC.sig == F & TCGA.sig == T ~ "TCGA only",
                                    TCC.sig == T & TCGA.sig == F ~ "TCC only"
    )) %>%
    as.data.frame()
  
  return(tmp.form)
}

resdir <- "/fs/ess/PAS1695/projects/exotic/data/correlations_mic-gene/"
res.files <- list.files(resdir, full.names = T)


res.ls <- lapply(res.files, loadSummarizeCorrs)
res.df <- bind_rows(res.ls)

saveRDS(res.df, "/fs/ess/PAS1695/projects/exotic/data/mic-genes_sigsum.RDS")


res.df %>%
  ggplot() +
  geom_mosaic(aes(x = product(sig.sum, dir.agree), fill = dir.agree),
              show.legend = F) +
  labs(x = "Effect direction", y = "Significant in") +
  scale_fill_manual(breaks = c("Agree", "Disagree"),
                    values = c("orange", "darkblue")) +
  theme_bw()
ggsave("~/Documents/repos/exoTCC/manuscripts/exoTiC/figures/mosaic_corr-mic-gene.pdf")


