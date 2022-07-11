format_for_voom_snm_expr_TCC <- function(tcc.exp, tcc.meta.linkage){
  site.resolutions <- read.csv(file_in("/fs/ess/PAS1695/exoticpipe/external-data/members-of-TCGA-groups.csv"),
                               stringsAsFactors = F, check.names = F) %>%
    dplyr::select(-n)
  tcc.exp <- tcc.exp %>%
    column_to_rownames(var = "gene_id") %>%
    t() %>%
    as.data.frame() %>%
    rownames_to_column(var = "sample")
  
  combcounts <- tcc.exp %>%
    dplyr::select("sample", everything())
  holdsamp <- combcounts$sample
  combcounts <- bind_cols(lapply(combcounts[,-1], function(x) ifelse(is.na(x), 0, x)))
  combcounts$sample <- holdsamp
  
  tcc.meta.form <- tcc.meta.linkage %>%
    left_join(site.resolutions) %>%
    mutate(ffpe.status = ifelse(`Tissue Preservation Method` == "FormalinFixed", TRUE, FALSE),
           SequencingCenter = "TCC",
           tissue_source_site = "Ohio State University",
           platform = "Illumina",
           concentration = NA)%>%
    rename("sample" = "LibraryID") %>%
    dplyr::select(sample, ffpe.status, SequencingCenter, tissue_source_site, TCGA.code, platform) %>%
    dplyr::filter(sample != "")
  
  combmeta <- tcc.meta.form %>%
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
