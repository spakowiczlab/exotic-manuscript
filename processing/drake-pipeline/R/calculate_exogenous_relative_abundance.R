calculate_exogenous_relative_abundance <- function(counts){
  tmp.totals <- calc.total.nosapiens(counts)
  
  tmp.ra.nosapien <- counts %>%
    # dplyr::select(-Homo.sapiens) %>%
    tidyr::gather(-sample, key = "microbe", value = "count") %>%
    left_join(tmp.totals) %>%
    mutate(ra = count/total) %>%
    dplyr::select(sample, microbe, ra) %>%
    spread(key = "microbe", value = "ra")
  
  return(tmp.ra.nosapien)
}

calc.total.nosapiens <- function(tmp){
  tmp.totals <- tmp %>%
    # dplyr::select(-Homo.sapiens) %>%
    tidyr::gather(-sample, key = "microbe", value = "count") %>%
    group_by(sample) %>%
    summarise(total = sum(count))
  
  return(tmp.totals)
}
