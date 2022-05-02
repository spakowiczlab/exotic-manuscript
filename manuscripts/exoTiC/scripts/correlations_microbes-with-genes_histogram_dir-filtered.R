library(tidyverse)

dirmatched <- readRDS("/fs/ess/PAS1695/projects/exotic/data/mic-genes_sigsum.RDS")
dirmatched.pass <- dirmatched %>%
  filter(dir.agree == "Agree") %>%
  select(microbe, Gene) %>%
  mutate(datset = "TCC")
rm(dirmatched)

loadMatchedCorrs <- function(fpath){
  tmp <- read.csv(fpath, stringsAsFactors = F)
  tmp.form <- tmp %>% 
    inner_join(dirmatched.pass)
  
  return(tmp.form)
}

resdir <- "/fs/ess/PAS1695/projects/exotic/data/correlations_mic-gene/"
res.files <- list.files(resdir, full.names = T)


res.ls <- lapply(res.files, loadMatchedCorrs)
res.df <- bind_rows(res.ls)

saveRDS(res.df, "/fs/ess/PAS1695/projects/exotic/data/correlations_mic-gene_TCC_dir-matched.RDS")

low.est <- quantile(res.df$estimate, 0.025, na.rm = T)
high.est <- quantile(res.df$estimate, 0.975, na.rm = T)

res.df %>%
  ggplot(aes(x = estimate)) +
  geom_histogram(bins = 200) +
  labs(x = "", y = "") +
  geom_vline(xintercept = low.est, lty = 2, color = "red") +
  geom_vline(xintercept = high.est, lty = 2, color = "red") +
  theme_bw() +
  theme(axis.text.y = element_blank(),
        axis.ticks.y = element_blank())
ggsave("../figures/histogram_correlation_mic-gene_TCC-dir-matched.pdf")


network.in <- res.df %>%
  filter(estimate < low.est | estimate > high.est)
saveRDS(network.in, "/fs/ess/PAS1695/projects/exotic/data/network_TCC-corr-in.RDS")
