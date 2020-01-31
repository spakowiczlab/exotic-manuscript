library(tidyverse)


# Read in the data

agg_exo.ra <- read.table("agg_exo-ra.txt", header = TRUE)

# dat <- agg_exo.ra[,2:447]
dat <- agg_exo.ra

# are there any NAs in the df
check <- is.na(dat)

sum(is.na(dat))
mean(is.na(dat))

# Fill any NAs with a 0
dat[is.na(dat)] <- 0

# Create id column 
# dat$id <- formatC(1:nrow(dat), width=3, flag="0")

names(dat)[1] <- "id"
names(dat)[grep("sample", names(dat))] <- "id"

grep("^id$", colnames(dat))

summary(dat$id)
head(dat$id)

bardat <- dat %>%
  gather(-id, -cancer, key = "micro", value = "percent")


bardat %>%
  ggplot(aes(x = cancer, y = percent, fill = micro))+
  geom_bar(position="fill", stat = "identity") +
  # theme(legend.position = "none") +
  ggsave("lesters-stacked-bar.pdf")

bardat %>%
  ggplot(aes(x = id, y = percent, fill = micro))+
  geom_bar(position="fill", stat = "identity") +
  theme(legend.position = "none") +
  ggsave("lesters-stacked-bar_samples.pdf", height = 10, width = 10)
