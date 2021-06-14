format_for_voom_snm <- function(tcc.counts, tcga.counts, tcc.meta, tcc.meta.linkage, tcga.meta){
  site.resolutions <- read.csv(file_in("/fs/scratch/PAS1695/exogitx/key_TCC-TCGA-origin-tissues.csv"),
                               stringsAsFactors = F)
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
    mutate(ffpe.status = ifelse(`Tumor Tissue Sequenced Specimen Category` == "Ambient", TRUE, FALSE),
           SequencingCenter = "TCC",
           tissue_source_site = "Ohio State University",
           platform = "Illumina",
           # THIS IS NOT GOOD! We need the tissue or organ of originin for the cancer, not sample site! will leave like this for now in the interest of having more data available
           SpecimenSiteOfOrigin = `Tumor Tissue Sequenced Collection Site`,
           concentration = NA)%>%
    rename("sample" = "tcc_id") %>%
    dplyr::select(sample, ffpe.status, SequencingCenter, tissue_source_site, SpecimenSiteOfOrigin, platform) %>%
    dplyr::filter(sample != "")
  
  tcga.meta.form <- tcga.meta %>%
    left_join(site.resolutions) %>%
    dplyr::select(-tissue_or_organ_of_origin)
  
  combmeta <- bind_rows(tcga.meta.form, tcc.meta.form) %>%
    arrange(sample) %>%
    dplyr::filter(!is.na(SpecimenSiteOfOrigin))
  
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
