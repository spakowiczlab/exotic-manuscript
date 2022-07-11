# This script should take a vector of TCGA uuids and produce a table of expression values in a specified location

library(optparse)
library(GenomicDataCommons)

option_list = list(
  # make_option(c("-i", "--ids"), type="character", default=NULL, 
  #             help="list TCGA uuids", metavar="character"),
  # make_option(c("-d", "--dir"), type="character", default=NULL, 
  #             help="gdc cache directory to use", metavar="character"),
  make_option(c("-t", "--tok"), type="character", default=NULL, 
              help="output file name [default= %default]", metavar="character"),
  make_option(c("-i", "--id"), type = "character", default = NULL, metavar="character")
) 

opt_parser = OptionParser(option_list=option_list)
opt = parse_args(opt_parser)


gdcdata(uuids = opt$id, token = opt$tok)

