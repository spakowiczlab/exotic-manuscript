library(tidyverse)

dirmatched <- readRDS("/fs/ess/PAS1695/projects/exotic/data/mic-genes_sigsum_regressions.RDS")
dirmatched.pass <- dirmatched %>%
  filter(dir.agree == "Agree") %>%
  select(microbe, gene) %>%
  mutate(datset = "TCC")
rm(dirmatched)

loadMatchedCorrs <- function(fpath){
  tmp <- read.csv(fpath, stringsAsFactors = F)
  tmp.form <- tmp %>% 
    filter(term != "(Intercept)" & !grepl("TCGA", term)) %>%
    inner_join(dirmatched.pass)
  
  return(tmp.form)
}

resdir <- "/fs/ess/PAS1695/projects/exotic/data/regressions_mic-gene/"
res.files <- list.files(resdir, full.names = T)


res.ls <- lapply(res.files, loadMatchedCorrs)
res.df <- bind_rows(res.ls)

saveRDS(res.df, "/fs/ess/PAS1695/projects/exotic/data/regressions_mic-gene_TCC_dir-matched.RDS")

low.est <- quantile(res.df$estimate, 0.025, na.rm = T)
high.est <- quantile(res.df$estimate, 0.975, na.rm = T)

res.df %>%
  ggplot(aes(x = estimate)) +
  geom_histogram(bins = 200) +
  labs(x = "Correlation estimate", y = "Frequency") +
  geom_vline(xintercept = low.est, lty = 2, color = "red") +
  geom_vline(xintercept = high.est, lty = 2, color = "red") +
  theme_bw() +
  theme(axis.text.y = element_blank(),
        axis.ticks.y = element_blank()) +
  theme(text = element_text(size = 10))
ggsave("~/Documents/repos/exoticpaper/analysisfigures/histogram_regression_mic-gene_TCC-dir-matched.pdf", 
       height = 3, width = 6)


network.in <- res.df %>%
  filter(estimate < low.est | estimate > high.est)
saveRDS(network.in, "/fs/ess/PAS1695/projects/exotic/data/network_TCC-reg-in.RDS")
