get_TCGA_clinical <- function(spec.cancs){
  files <- file.path("/fs/ess/PAS1695/generate-inputs_v2/TCGA-processing/data", spec.cancs, "clinical.csv")
  tcga.clinlist <- lapply(files, function(x) read.csv(file_in(x), stringsAsFactors = F))
  
  allclin <- bind_rows(bind_rows(tcga.clinlist))
  
  return(allclin)

}
