# library(dplyr)
# library(tibble)
library(vegan)

counts_to_rarefied_prevalenc <- function(startcounts){
  det.mins <- rowSums(startcounts)
  min.n <- min(det.mins)
  print(min.n)
  set.seed(112358)
  rare.counts <- rrarefy(x = startcounts, sample = min.n) %>%
    as.data.frame()
  rare.prev <- lapply(rare.counts, function(x) ifelse(x > 0, 1, 0))
  rare.prev.df <- bind_cols(rare.prev) %>%
    mutate(sample = rownames(startcounts)) %>%
    dplyr::select(sample, everything())
}
