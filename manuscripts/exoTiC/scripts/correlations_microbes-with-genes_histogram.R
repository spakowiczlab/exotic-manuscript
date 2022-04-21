library(tidyverse)

resdir <- "/fs/ess/PAS1695/projects/exotic/data/correlations_mic-gene/"
res.files <- list.files(resdir, full.names = T)

loadAssignBin <- function(fpath){
  tmp <- read.csv(fpath, stringsAsFactors = F)
  tmp.form <- tmp %>% 
    mutate(bin = floor(estimate*100)) %>%
    group_by(datset, bin) %>%
    tally()
  
  return(tmp.form)
}

bin.ls <- lapply(res.files, function(x) loadAssignBin(x))
bin.df <- bind_rows(bin.ls) %>%
  group_by(datset, bin) %>%
  summarise(n = sum(n))

write.csv(bin.df, "../data/correlations_mic-gene_binned.csv", row.names = F)
bin.df <- read.csv("../data/correlations_mic-gene_binned.csv", stringsAsFactors = F)

bin.df %>%
  mutate(bin.scaled = bin/100) %>%
  ggplot(aes(x = bin.scaled, y = n)) +
  facet_wrap(vars(datset)) +
  geom_col() +
  labs(x = "", y = "") +
  theme_bw() +
  theme(axis.text.y = element_blank(),
        axis.ticks.y = element_blank())
ggsave("../figures/histogram_correlation_mic-gene.pdf")
