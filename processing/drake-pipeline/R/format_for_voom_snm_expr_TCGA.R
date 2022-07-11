format_for_voom_snm_expr_TCGA <- function(tcga.exp, tcga.meta){
  tcga.exp <- tcga.exp %>%
    column_to_rownames(var = "Gene.Symbol") %>%
    t() %>%
    as.data.frame() %>%
    rownames_to_column(var = "file_id.expression") %>%
    mutate(file_id.expression = gsub("^X", "", file_id.expression),
           file_id.expression = gsub("\\.", "-", file_id.expression)) 
  
  combcounts <- tcga.exp %>%
    rename("sample" = "file_id.expression") %>%
    dplyr::select("sample", everything())
  holdsamp <- combcounts$sample
  combcounts <- bind_cols(lapply(combcounts[,-1], function(x) ifelse(is.na(x), 0, x)))
  combcounts$sample <- holdsamp

  tcga.meta.form <- tcga.meta %>%
    dplyr::select( -sample) %>%
    rename("sample" = "file_id.expression")
  
  combmeta <- tcga.meta.form %>%
    arrange(sample) %>%
    dplyr::filter(!is.na(TCGA.code))
  
  goodsamples <- intersect(combcounts$sample, combmeta$sample)
  combcounts <- combcounts %>%
    dplyr::filter(sample %in% goodsamples) %>%
    arrange(sample) %>%
    column_to_rownames(var = "sample") %>%
    as.matrix()
  combmeta <- combmeta %>%
    dplyr::filter(sample %in% goodsamples)
  
  combout <- list(combcounts, combmeta)
  
  return(combout)
  
}
