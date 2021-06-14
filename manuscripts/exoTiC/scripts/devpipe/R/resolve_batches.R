resolve_batches <- function(metadf, countdf, conc.col.name, sample.col.name, batch.col.name){

  metadf$sample <- metadf[[sample.col.name]]
  metadf$rna.conc <- as.numeric(metadf[[conc.col.name]])
  metadf$batch <- as.character(metadf[[batch.col.name]])
  
  metadf <- metadf %>%
    dplyr::filter(sample %in% countdf$sample) %>%
    add_count(batch) %>%
    dplyr::filter(n > 1) %>%
    arrange(sample)

  countdf <- countdf %>%
    as.data.frame() %>%
    dplyr::filter(sample %in% metadf$sample) %>%
    arrange(sample) 
  
  resolved.objects <- list(countdf, metadf)
  names(resolved.objects) <- c("counts", "meta")
  return(resolved.objects)
}
