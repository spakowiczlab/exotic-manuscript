grab_TCGA_metadata <- function(tcga.file.ids, tcga.expression.ids){
  grab.concentrations <- files() %>%
    GenomicDataCommons::select(c("file_id",
                                 "cases.samples.portions.analytes.aliquots.concentration",
                                 "analysis.metadata.read_groups.sequencing_center",
                                 "platform",
                                 "cases.tissue_source_site.name",
                                 "cases.samples.is_ffpe",
                                 "cases.diagnoses.tissue_or_organ_of_origin",
                                 "cases.project.project_id"
                                 # "plate_name"
                                 # "cases.samples.portions.analytes.well_number"
                                 )) %>%
    GenomicDataCommons::filter(file_id %in% tcga.file.ids) %>%
    results_all()
  
  # Trim that monster list
  
  form.conc <- list()
  cases <- names(grab.concentrations$cases)
  for(c in cases){
    form.conc[[c]] <- 
      grab.concentrations$cases[[c]]$samples[[1]]$portions[[1]]$analytes[[1]]$aliquots[[1]]
  }
  conc.df <- bind_rows(form.conc) %>%
    mutate(sample = grab.concentrations$file_id)
  
  form.seqcen <- list()
  for(i in 1:length(tcga.file.ids)){
    form.seqcen[[i]] <- 
      grab.concentrations$analysis$metadata$read_groups[[i]]$sequencing_center
  }
  names(form.seqcen) <- tcga.file.ids
  seqcen.df <- bind_rows(form.seqcen) %>%
    t() %>%
    as.data.frame() %>%
    mutate(sample = grab.concentrations$file_id) %>%
    rename("SequencingCenter" = "V1")
  
  form.ffpe <- list()
  for(i in 1:length(tcga.file.ids)){
    form.ffpe[[i]] <- 
      grab.concentrations$cases[[i]]$samples[[1]]$is_ffpe
  }
  form.ffpe <- unlist(form.ffpe)
  
  form.tsource <- list()
  for(i in 1:length(tcga.file.ids)){
    form.tsource[[i]] <- 
      grab.concentrations$cases[[i]]$tissue_source_site$name
  }
  form.tsource <- unlist(form.tsource)
  
  form.proj <- list()
  for(c in cases){
    form.proj[[c]] <- 
      grab.concentrations$cases[[c]]$project
  }
  proj.df <- bind_rows(form.proj) %>%
    mutate(sample = grab.concentrations$file_id,
           TCGA.code = gsub("TCGA-", "", project_id)) %>%
    dplyr::select(-project_id)
  
  form.torig <- list()
  for(i in 1:length(tcga.file.ids)){
    form.torig[[i]] <- 
      grab.concentrations$cases[[i]]$diagnoses[[1]]$tissue_or_organ_of_origin
  }
  names(form.torig) <- tcga.file.ids
  # We may need to switch to doing it this way for the other vars if the provided samples change
  form.torig <- bind_rows(form.torig) %>%
    t() %>%
    as.data.frame() %>%
    rownames_to_column(var = "sample") %>%
    rename("tissue_or_organ_of_origin" = "V1") %>%
    mutate(tissue_or_organ_of_origin = as.character(tissue_or_organ_of_origin))
  
  # form.well <- list()
  # cases <- names(grab.concentrations$cases)
  # for(c in cases){
  #   form.well[[c]] <- 
  #     grab.concentrations$cases[[c]]$samples[[1]]$portions[[1]]$analystes[[1]]$well_number
  # }
  # 
  
  meta.df <- conc.df %>%
    left_join(seqcen.df) %>%
    left_join(form.torig) %>%
    left_join(proj.df)
  
  meta.df$platform <- grab.concentrations$platform
  meta.df$tissue_source_site <- form.tsource
  meta.df$ffpe.status <- form.ffpe
  
  idkeys <- as.data.frame(cbind(sample = tcga.file.ids, file_id.expression = tcga.expression.ids))
  meta.df <- meta.df %>%
    left_join(idkeys)
  return(meta.df)
}
