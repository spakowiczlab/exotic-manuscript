check_human_percentages <- function(counts, req.percent){
  tmp <- counts %>%
    tidyr::gather(-sample, key = "microbe", value = "ct") %>%
    group_by(sample) %>%
    mutate(total.ct = sum(ct)) %>%
    ungroup() %>%
    dplyr::filter(microbe == "Homo.sapiens") %>%
    mutate(perc.hum = ct/total.ct) %>%
    dplyr::filter(perc.hum > req.percent)
  
  counts.pass <- counts %>%
    dplyr::filter(sample %in% tmp$sample)
  
  return(counts.pass)
}
