get_contaminants <- function(metadf, countdf){

  countdf <- countdf %>%
    column_to_rownames(var = "sample") %>%
    as.matrix()
  
  set.seed(112358)

  decontam.contams <- isContaminant(seqtab = countdf, conc = metadf$rna.conc, batch = metadf$batch) %>%
    rownames_to_column(var = "microbe") %>%
    tidyr::separate(microbe, into = c("Genera"), remove = F, sep = "\\.")

  return(decontam.contams)
}
