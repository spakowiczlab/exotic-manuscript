resolve_contaminants <- function(decontam.contams, tcga.filt.counts, threshold){
  salter.decontam <- read_excel("/fs/ess/PAS1695/exoticpipe/external-data/41586_2020_2095_MOESM2_ESM.xlsx", sheet = 6, skip = 1)
  salter.blanks <- read_excel("/fs/ess/PAS1695/exoticpipe/external-data/41586_2020_2095_MOESM2_ESM.xlsx", sheet = 7, skip = 1)
  
  salter.eval <- bind_rows(salter.decontam, salter.blanks)
  
  # If the decontam result is in salter, I want to use salter's judgment,otherwise the contaminant is removed
  decontam.badmics <- decontam.contams %>%
    dplyr::filter(p < threshold | is.na(p)) %>%
    dplyr::select(microbe, Genera)
  decontam.unq <- decontam.badmics[!duplicated(decontam.badmics[ , c("microbe", "Genera")]),]
  decontam.rem <- subset(decontam.unq, !(decontam.unq$Genera%in%salter.eval$Genera))
  
  salter.eval.rem <- salter.eval %>%
    dplyr::filter(Category == "LIKELY CONTAMINANT")
  salter.eval.rem <- unique(salter.eval.rem$Genera) 
  
  tcga.approved <- tcga.filt.counts %>%
    tidyr::gather(-sample, key = "microbe", value = "counts") %>%
    dplyr::filter(!microbe %in% decontam.rem$microbe) %>%
    tidyr::separate(microbe, into = c("Genera"), remove = F, sep = "\\.") %>%
    dplyr::filter(!Genera %in% salter.eval.rem) %>%
    dplyr::select(-Genera) %>%
    spread(key = "microbe", value = "counts")
  
 return(tcga.approved) 
}
