library(drake)

plan <- drake_plan(
  paths = source_paths(),
  
  raw.tcc.counts = readRDS(file.path(paths$drakeout, "raw.tcc.counts.RDS")),
  raw.tcga.counts = readRDS(file.path(paths$drakeout, "raw.tcga.counts.RDS")),
  tcc.counts = readRDS(file.path(paths$drakeout, "tcc.counts.RDS")),
  tcga.counts = readRDS(file.path(paths$drakeout, "tcga.counts.RDS")),
  tcc.contams = readRDS(file.path(paths$drakeout, "tcc.contams.RDS")),
  tcga.contams = readRDS(file.path(paths$drakeout, "tcga.contams.RDS")),
  tcga.batchres = readRDS(file.path(paths$drakeout, "tcga.batchres.RDS")),
  tcc.batchres = readRDS(file.path(paths$drakeout, "tcc.batchres.RDS")),
  tcc.exora.taxonomy = readRDS(file.path(paths$drakeout, "tcc.exora.taxonomy.RDS")),
  tcga.exora.taxonomy = readRDS(file.path(paths$drakeout, "tcga.exora.taxonomy.RDS")),
  
  contaminant.details = resolve_contaminants(bind_rows(tcc.contams, tcga.contams), 0.1)
  
  # figure_1 = rmarkdown::render(knitr_in("figure_1.RMD"),
  #                              output_file = file_out("figure_1.html"),
  #                              quiet = TRUE),
  
  # figure_2 = rmarkdown::render( knitr_in("figure_2.RMD"),
  #                               output_file = file_out("figure_2.html"),
  #                               quiet = TRUE),
  # 
  # figure_3 = rmarkdown::render( knitr_in("figure_3.Rmd"),
  #                               output_file = file_out("figure_3.html"),
  #                               quiet = TRUE)
)
  