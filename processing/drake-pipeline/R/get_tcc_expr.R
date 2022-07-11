get_tcc_expr <- function(samp.ids){
  tmp <- read.table("/fs/ess/PAS1695/exoticpipe/external-data/aggcuff_all.txt",
             header = T, sep = "\t", stringsAsFactors = F)
  
  tmp2 <- read.table("/fs/ess/PAS1695/projects/exotic/data/THY_expressions.txt", sep = "\t",
                     header = T) %>%
    mutate(gene_id = Gene.Symbol)
    
  tmp3 <- full_join(tmp,tmp2) %>%
    dplyr::select(any_of(c("gene_id", samp.ids)))
  
  return(tmp3)
}