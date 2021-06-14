plan <- drake_plan(
  raw.tcc.counts = readRDS("/fs/ess/PAS1695/projects/exotic/data/drake-output/2021-03-25/raw.tcc.counts.RDS"),
  raw.tcga.counts = readRDS("/fs/ess/PAS1695/projects/exotic/data/drake-output/2021-03-25/raw.tcga.counts.RDS"),
  
  tcc.meta = readRDS("/fs/ess/PAS1695/projects/exotic/data/drake-output/2021-03-25/tcc.meta.RDS"),
  tcc.meta.linkage = readRDS("/fs/ess/PAS1695/projects/exotic/data/drake-output/2021-03-25/tcc.meta.linkage.RDS"),
  tcga.meta = readRDS("/fs/ess/PAS1695/projects/exotic/data/drake-output/2021-03-25/tcga.meta.RDS"),
  
  lowhuman.samps = check_human_content(bind_rows(raw.tcc.counts, raw.tcga.counts)),
  tcc.counts = raw.tcc.counts %>%
    filter(!sample %in% lowhuman.samps),
  tcga.counts = raw.tcga.counts %>%
    filter(!sample %in% lowhuman.samps),
  
  tcc.batchres = resolve_batches(tcc.meta, tcc.counts, 
                                 "Concentration", "LibraryID", batch.col.name = "NexusBatchName"),
  tcga.batchres = resolve_batches(tcga.meta, tcga.counts, 
                                  "concentration", "sample", batch.col.name = "artbatch"),
  tcc.contams = get_contaminants(tcc.batchres$meta, tcc.batchres$counts),
  tcga.contams = get_contaminants(tcga.batchres$meta, tcga.batchres$counts),
  tcga.counts.filt = resolve_contaminants(bind_rows(tcc.contams, tcga.contams), tcga.batchres$counts, 0.1),
  good.mics = colnames(tcga.counts[,-1]),
  
  tcc.counts.filt = tcc.counts %>%
    dplyr::select(any_of(c("sample", good.mics))),
  
  normalization.inputs = format_for_voom_snm(tcc.counts.filt, tcga.counts.filt, tcc.meta, tcc.meta.linkage, tcga.meta),
  normalized.cpm  = voom_snm_normalization(normalization.inputs[[2]], normalization.inputs[[1]],
                                           "SpecimenSiteOfOrigin",
                                           c( "tissue_source_site",
                                              # "SequencingCenter",
                                              "ffpe.status")),
  tcga.counts.norm = tcga.meta %>%
    dplyr::select(sample) %>%
    inner_join(normalized.cpm),
  tcc.counts.norm = tcc.meta %>%
    rename("sample" = "LibraryID") %>%
    dplyr::select(sample) %>%
    inner_join(normalized.cpm),
  
  tcc.exora = calculate_exogenous_relative_abundance(tcc.counts.norm),
  tcga.exora = calculate_exogenous_relative_abundance(tcga.counts.norm),
  
  krakenmet = read.delim("/fs/ess/PAS1695/exoticpipe/external-data/kraken2-metaphlan-taxonomy.txt",
                         header = F, stringsAsFactors = F) %>%
    rename("Taxonomy" = "V1"),
  tcc.exora.taxonomy = assign_taxonomy(krakenmet, tcc.exora),
  tcga.exora.taxonomy = assign_taxonomy(krakenmet, tcga.exora),
)