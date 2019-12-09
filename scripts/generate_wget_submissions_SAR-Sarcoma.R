# generate_wget_subissions_SAR-Sarcoma.R
#
# script to generate a series of submission scripts to download the GI data
# 

urls <- readLines("download_urls/DNAnexus_export_urls-20191118-022941.txt")

wget.urls <- gsub("^(.*)", "wget \\1", urls)

urls.list <- split(wget.urls, 
                   ceiling(
                     seq_along(urls) / 10
                   )
)

dir.create("download_scripts/SAR-Sarcoma", recursive = TRUE)

for (l in 1:length(urls.list)) {
  
  fileConn <- file(paste0("download_scripts/SAR-Sarcoma/download_SAR_", 
                          l,
                          ".pbs")
                   )
  
  writeLines(c(paste0("#PBS -N download_SAR_", l),
               "#PBS -A PAS1460",
               "#PBS -l walltime=10:00:00",
               "#PBS -l nodes=1:ppn=1",
               "#PBS -j oe",
               "",
               "cd /fs/scratch/PAS1460/tcc_data/SAR-Sarcoma",
               paste(urls.list[[l]], sep = "\n"),
               ""),
             fileConn)
  close(fileConn)
}

