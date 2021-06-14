check_human_content <- function(rawcounts){
  human.ras <- rawcounts %>%
    tidyr::gather(-sample, key = "microbe", value = "counts") %>%
    group_by(sample) %>%
    mutate(totcounts = sum(counts, na.rm = T)) %>%
    dplyr::filter(microbe == "Homo.sapiens") %>%
    mutate(hs.ra = counts/totcounts)
  
  lowhum <- human.ras %>%
    filter(hs.ra < 0.05)
  lowhum.snames <- lowhum$sample
  
  return(lowhum.snames)
  
}
