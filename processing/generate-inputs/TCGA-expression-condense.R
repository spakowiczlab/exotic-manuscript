# This script should take a vector of TCGA uuids and produce a table of expression values in a specified location

library(optparse)
# library(GenomicDataCommons)
library(dplyr)
library(tidyr)
library(tibble)
library(annotate)
library(org.Hs.eg.db)
library(WGCNA)


# option_list = list(
#   # make_option(c("-i", "--ids"), type="character", default=NULL, 
#   #             help="list TCGA uuids", metavar="character"),
#   make_option(c("-d", "--dir"), type="character", default=NULL, 
#               help="gdc cache directory to use", metavar="character"),
#   make_option(c("-o", "--out"), type="character", default="out.txt", 
#               help="output file name [default= %default]", metavar="character")
# ) 
# 
# opt_parser = OptionParser(option_list=option_list)
# opt = parse_args(opt_parser)

opt <- as.data.frame(cbind(dir = "/fs/ess/PAS1695/generate-inputs_v2/TCGA-processing/data/BLCA/tmp-expression",
                          out = "/fs/ess/PAS1695/generate-inputs_v2/TCGA-processing/data/BLCA/expressions.txt"))
setwd(opt$dir)
getwd()

fileids <- list.files()
filenames <- unlist(lapply(fileids, function(x) list.files(x)))

goodpaths <- as.data.frame(cbind(fileids, filenames)) %>%
  mutate(filepaths = paste0(fileids, "/", filenames))

fileids
filenames
# goodpaths$filepaths[1]

septabs <- lapply(goodpaths$filepaths, function(x) read.table(x, stringsAsFactors = F, header = F))
names(septabs) <- fileids

septabs.addnames <- lapply(names(septabs),function(x) septabs[[x]] %>% mutate(file_id.expression = x))

combsamps <- bind_rows(septabs.addnames) %>%
  mutate(V1 = gsub("(.*)\\..*", "\\1", V1)) %>%
  spread(key = "file_id.expression", value = "V2")

combsamps.rembad <- combsamps %>%
  dplyr::filter(grepl("ENS", V1)) %>%
  column_to_rownames(var = "V1")

gene.syms <- mapIds(org.Hs.eg.db, keys = rownames(combsamps.rembad), keytype = "ENSEMBL", column = "SYMBOL")

combsamps.col <- collapseRows(combsamps.rembad, rowID = rownames(combsamps.rembad), rowGroup = gene.syms)

combsamps.form <- combsamps.col$datETcollapsed %>%
  as.data.frame() %>%
  rownames_to_column(var = "Gene.Symbol")

write.table(x = combsamps.form, file = opt$out, row.names = F, sep = "\t", quote = F)
system(paste0("rm -r ", opt$dir))
