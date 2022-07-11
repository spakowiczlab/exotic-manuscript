# This script should take a vector of TCGA uuids and produce a table of expression values in a specified location

library(dplyr)
library(tidyr)
library(tibble)
library(stringr)



aggregate.dat <- function(dir.path, out.file){

fileids <- list.files(dir.path, full.names = T)
filenames <- gsub("\\.txt", "", list.files(dir.path))
septabs <- lapply(fileids, function(x) read.delim(x, header = TRUE, sep = "\t", stringsAsFactors = FALSE))
names(septabs) <- filenames

septabs.addnames <- lapply(names(septabs),function(x) septabs[[x]] %>% mutate(sample = x))%>%
  bind_rows() %>%
  mutate(name = make.names(name)) 


aggtab <- septabs.addnames %>%
  # mutate(name = str_trunc(name, 9999, "right")) %>%
  dplyr::select(name, sample, new_est_reads) %>%
  spread(key = "name", value = "new_est_reads") %>%
  tidyr::gather(-sample, key = "name", value = "new_est_reads") %>%
  mutate(new_est_reads = ifelse(is.na(new_est_reads), 0, new_est_reads)) %>%
  spread(key = "name", value = "new_est_reads")

write.table(x = aggtab,file = out.file, row.names = FALSE, quote=FALSE, sep = "\t")
# system(paste0("rm -r ", dir.path))
}

# Function for including human counts
add_human_counts <- function(cpath, fstat){
  bamstats.files <- list.files(file.path(cpath, fstat), full.names = T)
  bamstat.snames <- list.files(file.path(cpath, fstat))
  bammapped.ls <- unlist(lapply(bamstats.files, function(x) readLines(x)[5]))
  names(bammapped.ls) <- gsub("(.*)\\.txt", "\\1", bamstat.snames)
  bammapped.form <- bammapped.ls %>%
    as.data.frame() %>%
    rownames_to_column(var = "sample") %>%
    rename("HS.mapped" = ".") %>%
    mutate(HS.mapped = as.numeric(gsub(" +.*", "", HS.mapped)))
  
  k2bout <- read.delim(file.path(cpath, "k2bout.txt"), sep = "\t", header = T)
  
  k2baddhum <- k2bout %>%
    left_join(bammapped.form) %>%
    mutate(Homo.sapiens = Homo.sapiens + HS.mapped) %>%
    dplyr::select(-HS.mapped)
  
  write.table(k2baddhum, file.path(cpath, "k2b_add-human.txt"), quote = F, row.names = F, sep = "\t")
}

# Some pre-typed usages
TCGA.prefix <- "/fs/ess/PAS1695/generate-inputs_v2/TCGA-processing/data"
TCGA.cancer <- "LUAD"
aggregate.dat(file.path(TCGA.prefix, TCGA.cancer, "bracken-out/"), 
              file.path(TCGA.prefix, TCGA.cancer, "k2bout.txt"))

add_human_counts(file.path(TCGA.prefix, TCGA.cancer), "unaligned_extraction-stats")




