get_TCGA_expr <- function(spec.cancs){
  files <- file.path("/fs/ess/PAS1695/generate-inputs_v2/TCGA-processing/data", spec.cancs, "expressions.txt")
  counts.aftergen <- lapply(files, function(x) read.table(file_in(x), header = T, sep = "\t", stringsAsFactors = F,
                                                          check.names = F))
  
  rawcounts.all <- counts.aftergen %>% purrr::reduce(full_join, by = "Gene.Symbol")
  
  return(rawcounts.all)
}
