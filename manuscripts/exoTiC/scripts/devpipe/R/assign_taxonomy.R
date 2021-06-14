assign_taxonomy <- function(met.all, exo.obj){
  met.good <- met.all %>%
    dplyr::filter(!grepl("\n", Taxonomy))
  met.fix <- met.all %>%
    dplyr::filter(grepl("\n", Taxonomy)) 
  
  fix.taxa.amalgam <- paste(met.fix$Taxonomy, collapse = "\n")
  fix.taxa.split <- str_split(pattern = "\n", fix.taxa.amalgam)[[1]]
  met.repared <- as.data.frame(cbind(Taxonomy = fix.taxa.split,
                                     V2 = 1))%>%
    tidyr::separate(Taxonomy, into = c("Taxonomy"), sep = "\t") %>%
    mutate(V2 = as.numeric(as.character(V2)))
  
  taxkey <- bind_rows(met.good, met.repared) %>%
    dplyr::filter(grepl("s__", Taxonomy)) %>%
    mutate(specjoin = gsub(".*s__(.*)", "\\1", Taxonomy),
           specjoin = make.names(specjoin))
  
  exo.obj.tax <- exo.obj %>%
    tidyr::gather(-sample, key = "microbe", value = "exo.ra") %>%
    mutate(specjoin = microbe)%>%
    left_join(taxkey) %>%
    mutate(domain = gsub("(d__\\w+).*", "\\1", Taxonomy),
           kingdom = ifelse(grepl("k__", Taxonomy),gsub(".*(k__\\w+).*", "\\1", Taxonomy), NA),
           phylum = ifelse(grepl("p__", Taxonomy),gsub(".*(p__\\w+).*", "\\1", Taxonomy), NA),
           order = ifelse(grepl("o__", Taxonomy),gsub(".*(o__\\w+).*", "\\1", Taxonomy), NA),
           class = ifelse(grepl("c__", Taxonomy),gsub(".*(c__\\w+).*", "\\1", Taxonomy), NA),
           family = ifelse(grepl("f__", Taxonomy),gsub(".*(f__\\w+).*", "\\1", Taxonomy), NA),
           genus = ifelse(grepl("g__", Taxonomy),gsub(".*(g__\\w+).*", "\\1", Taxonomy), NA),
           species = gsub(".*(s__.*)", "\\1", Taxonomy)
    ) %>%
    mutate(genus = ifelse(is.na(genus), paste0("g__unclassified-", species), genus),
           family = ifelse(is.na(family), paste0("f__unclassified-", gsub("g__unclassified-", "", genus)), family),
           order = ifelse(is.na(order), paste0("o__unclassified-", gsub("f__unclassified-", "", family)), order),
           class = ifelse(is.na(class), paste0("c__unclassified-", gsub("o__unclassified-", "", order)), class),
           phylum = ifelse(is.na(phylum), paste0("p__unclassified-", gsub("c__unclassified-", "", class)),phylum),
           kingdom = ifelse(is.na(kingdom), paste0("k__unclassified-", gsub("p__unclassified-", "", phylum)), kingdom),
           domain = ifelse(is.na(domain), paste0("d__unclassified-", gsub("k__unclassified-", "", kingdom)), domain)) %>%
    dplyr::select(sample, microbe, Taxonomy, domain, kingdom, phylum, class, order, family, genus, species, exo.ra)
  
  return(exo.obj.tax)
  
}
