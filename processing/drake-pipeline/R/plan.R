library(drake)

plan.TCCandTCGA <- drake_plan(
  #PM manually determined these samples were not from patients with GI cancers
  tcc.badslids = c("SL242316", "SL242362", "SL242315", "SL242435", "SL346424"),
  
  tcga.clin.raw = get_TCGA_clinical(tcga.cancers),
  tcga.clin.tum = tcga.clin.raw %>%
    dplyr::filter(source == "tumor"),
  
  tcc.meta = readxl::read_excel(file_in("/fs/ess/PAS1695/exoticpipe/external-data/OSU.RNAseq.sequencing.QC.metrics.xlsx")) %>%
    dplyr::filter(!LibraryID %in% tcc.badslids),
  # tcc.meta.linkage = read.csv(file_in("/fs/scratch/PAS1695/projects/exoN/data/metadata/raw/OSU_Clinical_Specimen_Linkage_Data_Full_20200526.csv"),
  #                             stringsAsFactors = F),
  tcc.meta.linkage = read_excel("/fs/ess/PAS1695/exoticpipe/external-data/Spakowicz - Exotic -Avatar RNASeq Ids with Sites 2021.11.17.xlsx"),
  tcga.meta = grab_TCGA_metadata(tcga.clin.tum$file_id.BAM, tcga.clin.tum$file_id.expression) %>%
    mutate(artbatch = paste0(tissue_source_site, ffpe.status)),

  raw.tcc.counts = get_TCC_rawcounts(tcc.cancers) %>%
    dplyr::filter(!sample %in% tcc.badslids),
  raw.tcga.counts = get_TCGA_rawcounts(tcga.cancers),
  
  tcc.counts.passHS = check_human_percentages(raw.tcc.counts, .95),
  tcga.counts.passHS = check_human_percentages(raw.tcga.counts, .95),
  
  tcc.batchres = resolve_batches(tcc.meta, tcc.counts.passHS, 
                                 "Concentration", "LibraryID", batch.col.name = "NexusBatchName"),
  tcga.batchres = resolve_batches(tcga.meta, tcga.counts.passHS, 
                                  "concentration", "sample", batch.col.name = "artbatch"),
  tcc.contams = get_contaminants(tcc.batchres$meta, tcc.batchres$counts),
  tcga.contams = get_contaminants(tcga.batchres$meta, tcga.batchres$counts),
  tcga.counts = resolve_contaminants(bind_rows(tcc.contams, tcga.contams), tcga.batchres$counts, 0.1),
  good.mics = colnames(tcga.counts[,-1]),
  
  tcc.counts = tcc.counts.passHS %>%
    dplyr::select(any_of(c("sample", good.mics))),
  
  normalization.inputs = format_for_voom_snm(tcc.counts, tcga.counts, tcc.meta, tcc.meta.linkage, tcga.meta),
  normalized.cpm  = voom_snm_normalization(normalization.inputs[[2]], normalization.inputs[[1]],
                                              "TCGA.code",
                                              c( "SequencingCenter")),
  tcga.counts.norm = tcga.meta %>%
    dplyr::select(sample) %>%
    inner_join(normalized.cpm),
  tcc.counts.norm = tcc.meta %>%
    rename("sample" = "LibraryID") %>%
    dplyr::select(sample) %>%
    inner_join(normalized.cpm),
  
  tcc.exora = calculate_exogenous_relative_abundance(tcc.counts.norm),
  tcga.exora = calculate_exogenous_relative_abundance(tcga.counts.norm),
  
  krakenmet = read.delim("/fs/ess/PAS1695/exoticpipe/external-data/kraken2-metaphlan-noplants.txt",
                         header = F, stringsAsFactors = F) %>%
    rename("Taxonomy" = "V1"),
  tcc.exora.taxonomy = assign_taxonomy(krakenmet, tcc.exora),
  tcga.exora.taxonomy = assign_taxonomy(krakenmet, tcga.exora),
  
  tcga.expr = get_TCGA_expr(tcga.cancers),
  tcga.expr.red = remove_low_human_TCGA(tcga.expr, tcga.counts.passHS, tcga.meta),
  tcc.expr = get_tcc_expr(tcc.counts.passHS$sample),
  
  normalization.inputs.expr = format_for_voom_snm_expr(tcc.expr, tcga.expr.red, tcc.meta, tcc.meta.linkage, tcga.meta),
  normalized.expr  = voom_snm_normalization_expr(normalization.inputs.expr[[2]], normalization.inputs.expr[[1]],
                                           "TCGA.code",
                                           c("SequencingCenter")),
  tcga.expr.norm = tcga.clin.tum %>%
    rename("sample" = "file_id.expression") %>%
    dplyr::select(sample) %>%
    inner_join(normalized.expr),
  tcc.expr.norm = tcc.meta %>%
    rename("sample" = "LibraryID") %>%
    dplyr::select(sample) %>%
    inner_join(normalized.expr)

)

plan.TCGA <- drake_plan(
  tcga.clin.raw = get_TCGA_clinical(tcga.cancers),
  tcga.clin.tum = tcga.clin.raw %>%
    dplyr::filter(source == "tumor"),
  tcga.meta = grab_TCGA_metadata(tcga.clin.tum$file_id.BAM, tcga.clin.tum$file_id.expression) %>%
    mutate(artbatch = paste0(tissue_source_site, ffpe.status)),
  
  raw.tcga.counts = get_TCGA_rawcounts(tcga.cancers),
  tcga.counts.passHS = check_human_percentages(raw.tcga.counts, .95),
  tcga.batchres = resolve_batches(tcga.meta, tcga.counts.passHS, 
                                  "concentration", "sample", batch.col.name = "artbatch"),
  tcga.contams = get_contaminants(tcga.batchres$meta, tcga.batchres$counts),
  tcga.counts = resolve_contaminants(tcga.contams, tcga.batchres$counts, 0.1),
  
  normalization.inputs = format_for_voom_snm_TCGA(tcga.counts, tcga.meta),
  tcga.counts.norm  = voom_snm_normalization(normalization.inputs[[2]], normalization.inputs[[1]],
                                           "TCGA.code",
                                           c( "tissue_source_site",
                                              # "SequencingCenter",
                                              "ffpe.status")),

  tcga.exora = calculate_exogenous_relative_abundance(tcga.counts.norm),
  
  krakenmet = read.delim("/fs/ess/PAS1695/exoticpipe/external-data/kraken2-metaphlan-noplants.txt",
                         header = F, stringsAsFactors = F) %>%
    rename("Taxonomy" = "V1"),
  tcga.exora.taxonomy = assign_taxonomy(krakenmet, tcga.exora),
  
  tcga.expr = get_TCGA_expr(tcga.cancers),
  tcga.expr.red = remove_low_human_TCGA(tcga.expr, tcga.counts.passHS, tcga.meta),
  normalization.inputs.expr = format_for_voom_snm_expr_TCGA(tcga.expr.red, tcga.meta),
  tcga.expr.norm  = voom_snm_normalization_expr(normalization.inputs.expr[[2]], normalization.inputs.expr[[1]],
                                                 "TCGA.code",
                                                 c( "tissue_source_site",
                                                    # "SequencingCenter",
                                                    "ffpe.status"))

)

plan.TCC <- drake_plan(
  #PM manually determined these samples were not from patients with GI cancers
  tcc.badslids = c("SL242316", "SL242362", "SL242315", "SL242435", "SL346424"),
  
  tcc.meta = readxl::read_excel(file_in("/fs/ess/PAS1695/exoticpipe/external-data/OSU.RNAseq.sequencing.QC.metrics.xlsx")) %>%
    dplyr::filter(!LibraryID %in% tcc.badslids),
  # tcc.meta.linkage = read.csv(file_in("/fs/scratch/PAS1695/projects/exoN/data/metadata/raw/OSU_Clinical_Specimen_Linkage_Data_Full_20200526.csv"),
  #                             stringsAsFactors = F),
  tcc.meta.linkage = read_excel("/fs/ess/PAS1695/exoticpipe/external-data/Additional Data_Spakowicz_SLids.xlsx"),
  
  raw.tcc.counts = get_TCC_rawcounts(tcc.cancers) %>%
    dplyr::filter(!sample %in% tcc.badslids),
  tcc.counts.passHS = check_human_percentages(raw.tcc.counts, .95),
  
  tcc.batchres = resolve_batches(tcc.meta, tcc.counts.passHS, 
                                 "Concentration", "LibraryID", batch.col.name = "NexusBatchName"),
  
  tcc.contams = get_contaminants(tcc.batchres$meta, tcc.batchres$counts),
  tcc.counts = resolve_contaminants(tcc.contams, tcc.counts.passHS, 0.1),
  
  normalization.inputs = format_for_voom_snm_TCC(tcc.counts,tcc.meta.linkage),
  tcc.counts.norm  = voom_snm_normalization(normalization.inputs[[2]], normalization.inputs[[1]],
                                            "SpecimenSiteOfOrigin","ffpe.status"), 
  
  #   tcc.counts.norm = tcc.meta %>%
  #      rename("sample" = "LibraryID") %>%
  #      dplyr::select(sample) %>%
  #      inner_join(normalized.cpm),
  
  tcc.exora = calculate_exogenous_relative_abundance(tcc.counts.norm),
  
  krakenmet = read.delim("/fs/ess/PAS1695/exoticpipe/external-data/kraken2-metaphlan-noplants.txt",
                         header = F, stringsAsFactors = F) %>%
    rename("Taxonomy" = "V1"),
  tcc.exora.taxonomy = assign_taxonomy(krakenmet, tcc.exora),
  
  tcc.expr = get_tcc_expr(tcc.counts.passHS$sample),
  normalization.inputs.expr = format_for_voom_snm_expr_TCC(tcc.expr, tcc.meta.linkage),
  normalized.expr = voom_snm_normalization_expr(normalization.inputs.expr[[2]], normalization.inputs.expr[[1]],
                                                "TCGA.code", "ffpe.status")
  
)
