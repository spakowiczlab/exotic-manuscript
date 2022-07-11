format_for_voom_snm_TCGA <- function(tcga.counts,tcga.meta){
  
  combmeta <- tcga.meta %>%
    arrange(sample) %>%
    dplyr::filter(!is.na(TCGA.code))
  
  goodsamples <- intersect(tcga.counts$sample, combmeta$sample)
  combcounts <- tcga.counts %>%
    dplyr::filter(sample %in% goodsamples) %>%
    arrange(sample) %>%
    column_to_rownames(var = "sample") %>%
    as.matrix()
  combmeta <- combmeta %>%
    dplyr::filter(sample %in% goodsamples)
  
  combout <- list(combcounts, combmeta)
  
  return(combout)
  
}
