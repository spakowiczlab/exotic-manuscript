library(stackoverflow)
library(docopt)

'Usage:
   compres-functions.R [-c <cancer>]

Options:
   -c name of cancer to be compressed. Should be in tcc_data/fastqs.

 ]' -> doc

opts <- docopt(doc)

directory.tcc.fastqs <- "/fs/scratch/PAS1460/tcc_data/fastqs/"
directory.compress <- "/fs/scratch/PAS1460/exoTCC/data/compressed-tcc/"

get.compress.groups <- function(canc.dir){
  numsplits <- list.files(paste0(directory.tcc.fastqs, canc.dir), pattern = "download")
  fastq.files <- list.files(paste0(directory.tcc.fastqs, canc.dir), pattern = "SL")
  compress.list <- chunk2(fastq.files, length(numsplits))
  return(compress.list)
}

format.compress.command <- function(compress.group, cancer, splitnum){
  files.with.dir <- paste0(directory.tcc.fastqs, cancer, "/", compress.group)
  comb.files <- paste(files.with.dir, collapse = " ")
  tar.command <- paste0("tar -cvzf ",
                        directory.compress, cancer, "_", splitnum, ".tar.gz ",
                        comb.files)
  return(tar.command)
}

compress.cancer <- function(cname){
  tmp.comp.list <- get.compress.groups(cname)
  nsplits <- length(tmp.comp.list)
  nsplits
  coms.to.run <- lapply(1:nsplits, function(x) format.compress.command(tmp.comp.list[[x]], cname, x))
  lapply(coms.to.run, function(x) system(x))
}

compress.cancer(opts$c)
