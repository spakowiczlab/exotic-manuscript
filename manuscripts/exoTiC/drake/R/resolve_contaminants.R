resolve_contaminants <- function(decontam.contams, threshold){
  salter.decontam <- read_excel("/fs/scratch/PAS1695/exogitx/data/41586_2020_2095_MOESM2_ESM.xlsx", sheet = 6, skip = 1)
  salter.blanks <- read_excel("/fs/scratch/PAS1695/exogitx/data/41586_2020_2095_MOESM2_ESM.xlsx", sheet = 7, skip = 1)
  
  salter.eval <- bind_rows(salter.decontam, salter.blanks)
  
  # If the decontam result is in salter, I want to use salter's judgment,otherwise the contaminant is removed
  decontam.badmics <- decontam.contams %>%
    dplyr::filter(p < threshold)
  decontam.unq <- decontam.badmics[!duplicated(decontam.badmics[ , c("microbe", "Genera")]),]
  # decontam.rem <- subset(decontam.unq, !(decontam.unq$Genera%in%salter.eval$Genera))
  
  salter.eval.rem <- decontam.contams %>%
    left_join(salter.eval) %>%
    filter(Category == "LIKELY CONTAMINANT" | (is.na(Category) & (p<threshold)))
  salter.eval.rem <- unique(salter.eval.rem$microbe) 
  
  resolved.results <- list(salter.eval.rem, decontam.unq)
  names(resolved.results) <- c("salter.informed.contaminants", "decontam.contaminants")
  return(resolved.results) 
}
