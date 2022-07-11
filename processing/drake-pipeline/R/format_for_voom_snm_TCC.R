format_for_voom_snm_TCC <- function(tcc.counts,tcc.meta.linkage){
  site.resolutions <- read.csv(file_in("/fs/ess/PAS1695/exoticpipe/external-data/members-of-TCGA-groups.csv"),
                               stringsAsFactors = F, check.names = F) %>%
    dplyr::select(-n)
  combmeta <- tcc.meta.linkage %>%
    left_join(site.resolutions) %>%
    mutate(ffpe.status = ifelse(`Tissue Preservation Method` == "FormalinFixed", TRUE, FALSE),
           SequencingCenter = "TCC",
           tissue_source_site = "Ohio State University",
           platform = "Illumina",
           concentration = NA)%>%
    rename("sample" = "LibraryID") %>%
    dplyr::select(sample, ffpe.status, SequencingCenter, tissue_source_site, TCGA.code, platform) %>%
    dplyr::filter(sample != "")
  
  goodsamples <- intersect(tcc.counts$sample, combmeta$sample)
  combcounts <- tcc.counts %>%
    dplyr::filter(sample %in% goodsamples) %>%
    arrange(sample) %>%
    column_to_rownames(var = "sample") %>%
    as.matrix()
  combmeta <- combmeta %>%
    dplyr::filter(sample %in% goodsamples)
  
  combout <- list(combcounts, combmeta)
  
  return(combout)
  
}