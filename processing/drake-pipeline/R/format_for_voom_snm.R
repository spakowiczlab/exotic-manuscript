format_for_voom_snm <- function(tcc.counts, tcga.counts, tcc.meta, tcc.meta.linkage, tcga.meta){
  site.resolutions <- read.csv(file_in("/fs/ess/PAS1695/exoticpipe/external-data/members-of-TCGA-groups.csv"),
                               stringsAsFactors = F, check.names = F) %>%
    dplyr::select(-n)
  combcounts <- bind_rows(tcc.counts, tcga.counts)
  holdsamp <- combcounts$sample
  combcounts <- bind_cols(lapply(combcounts[,-1], function(x) ifelse(is.na(x), 0, x)))
  combcounts$sample <- holdsamp
  
  # As of now, TCGA refers to "platform" as Illumina, which also made all of our machines.
  # If I find info on specific machines for TCGA I will update this.
  # tcc.meta.plat <- tcc.meta %>%
  #   rename("sample" = "LibraryID",
  #          "platform" = "sequencer_type") %>%
  #   dplyr::select(sample, platform)
  
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
  
  tcga.meta.form <- tcga.meta %>%
    dplyr::select(-tissue_or_organ_of_origin)
  
  combmeta <- bind_rows(tcga.meta.form, tcc.meta.form) %>%
    arrange(sample) %>%
    dplyr::filter(!is.na(TCGA.code))
  
  goodsamples <- intersect(combcounts$sample, combmeta$sample)
  combcounts <- combcounts %>%
    dplyr::filter(sample %in% goodsamples) %>%
    arrange(sample) %>%
    column_to_rownames(var = "sample") %>%
    as.matrix()
  combmeta <- combmeta %>%
    dplyr::filter(sample %in% goodsamples) %>%
    mutate(norm.adjvars = paste0(tissue_source_site, ffpe.status,SequencingCenter))
  
  combout <- list(combcounts, combmeta)
  
  return(combout)
  
}
