library(tidyverse)

concordance <- read.csv("../tables/survival_concordance.csv", stringsAsFactors = F) %>%
  filter(agree.code == T)

degree <- read.csv("../tables/S2_network_microbe_degree-centrality.csv")
close <- read.csv("../tables/network_closeness-centrality_regression.csv")
between <- read.csv("../tables/network_betweenness-centrality_regression.csv")

degree.join <- degree %>%
  select(microbe, rank) %>%
  rename("rank_degree.centrality" = "rank")

close.join <- close %>%
  arrange(desc(closeness)) %>%
  mutate(rank = row_number(),
         microbe = node) %>%
  select(microbe, rank) %>%
  rename("rank_closeness.centrality" = "rank")

between.join <- between %>%
  arrange(desc(betweencent)) %>%
  mutate(rank = row_number(),
         microbe = node) %>%
  select(microbe, rank) %>%
  rename("rank_betweenness.centrality" = "rank")


tableS8 <- concordance %>%
  left_join(degree.join) %>%
  left_join(close.join) %>%
  left_join(between.join)

write.csv(tableS8, "../tables/summary_survival-network.csv")
