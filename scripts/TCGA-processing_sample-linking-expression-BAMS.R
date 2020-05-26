library(GenomicDataCommons)

# Acquire information of expresion files
setwd("C:/Users/hoyd02/Box Sync/exoTCC/gdc-download/COAD-READ_expression")
file.uuids <- list.files()
file.names <- lapply(file.uuids, function(x) list.files(x))

file.dat <- as.data.frame(cbind(file.uuids, file.name = unlist(file.names))) %>%
  mutate(file.uuids = as.character(file.uuids),
         file.name = as.character(file.name),
         is.count = ifelse(grepl("count", file.name), TRUE, FALSE),
         common.id = gsub("(.*)\\..*\\..*\\..*", "\\1", file.name))

# Pull iinformation from BAM ids

setwd("../../../2020-05-31_ASCO_PM_exotcc-gi/data/tcga/")

bam.dat <- read.csv("GI_TCGA-clinical.csv", stringsAsFactors = F)

# Lood to link the samples
test <- available_fields("files")

linksamps <- files() %>%
  select(c("file_id", "downstream_analyses.output_files.file_name")) %>%
  filter(~ file_id %in% bam.dat$file_id) %>%
  results_all()

sampids <- list()

for(i in linksamps$id){
  sampids[[i]] <- linksamps$downstream_analyses[[i]]$output_files[[1]]$file_name
}

try.names <- gsub("(.*)\\..*\\..*\\..*", "\\1", unlist(sampids))

any(file.dat$common.id %in% try.names)
#SUCESSS! now let's make the key

bam.expression.key <- as.data.frame(cbind(file_id.BAM = names(try.names), file_id.expression = try.names)) %>%
  remove_rownames()

# write.csv(bam.expression.key,
#           "C:/Users/hoyd02/Documents/repos/exoTCC/data/TCGA-link-bam-and-expression-files.csv", 
#           row.names = F)
