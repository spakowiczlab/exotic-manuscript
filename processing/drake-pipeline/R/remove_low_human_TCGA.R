remove_low_human_TCGA <- function(expr, passdf, meta){
  passed.samps <- passdf %>%
    dplyr::select(sample) %>%
    left_join(meta) %>%
    mutate(file_id.expression = as.character(file_id.expression))
  
  expr.filt <- expr %>%
    dplyr::select(c("Gene.Symbol", passed.samps$file_id.expression))
  
  return(expr.filt)
}
