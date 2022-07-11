get_TCGA_rawcounts <- function(spec.cancs){
  files <- file.path("/fs/ess/PAS1695/generate-inputs_v2/TCGA-processing/data", spec.cancs, "k2b_add-human.txt")
  counts.aftergen <- lapply(files, function(x) read.table(file_in(x), header = T, sep = "\t", stringsAsFactors = F))
  
  rawcounts.all <- bind_rows(counts.aftergen)
  holdsamp <- rawcounts.all$sample
  rawcounts.all <- bind_cols(lapply(rawcounts.all[,-1], function(x) ifelse(is.na(x), 0, x)))
  rawcounts.all$sample <- holdsamp
  rawcounts.all <- rawcounts.all %>%
    dplyr::select(sample, everything())
  
  return(rawcounts.all)
}
