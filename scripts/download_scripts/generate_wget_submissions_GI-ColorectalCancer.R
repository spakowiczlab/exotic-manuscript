# generate_wget_subissions_GI-ColorectalCancer.R
#
# script to generate a series of submission scripts to download the GI data
# 

urls <- readLines("download_urls/DNAnexus_export_urls-20191118-120313.txt")

wget.urls <- gsub("^(.*)", "wget \\1", urls)

urls.list <- split(wget.urls, 
                   ceiling(
                     seq_along(urls) / 10
                   )
)

dir.create("download_scripts/GI-ColorectalCancer", recursive = TRUE)

for (l in 1:length(urls.list)) {
  
  fileConn <- file(paste0("download_scripts/GI-ColorectalCancer/download_GI_", 
                          l,
                          ".pbs")
                   )
  
  writeLines(c(paste0("#PBS -N download_GI_", l),
               "#PBS -A PAS1460",
               "#PBS -l walltime=10:00:00",
               "#PBS -l nodes=1:ppn=1",
               "#PBS -j oe",
               "",
               "cd /fs/scratch/PAS1460/tcc_data/GI-ColorectalCancer",
               paste(urls.list[[l]], sep = "\n"),
               ""),
             fileConn)
  close(fileConn)
}
