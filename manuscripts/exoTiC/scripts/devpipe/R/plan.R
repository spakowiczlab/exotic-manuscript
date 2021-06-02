plan <- drake_plan(
  raw.tcc.counts = readRDS("/fs/ess/PAS1695/projects/exotic/data/drake-output/2021-03-25/raw.tcc.counts.RDS"),
  raw.tcga.counts = readRDS("/fs/ess/PAS1695/projects/exotic/data/drake-output/2021-03-25/raw.tcga.counts.RDS"),
  lowhuman.samps = check_human_content(bind_rows(raw.tcc.counts, raw.tcga.counts)),
)