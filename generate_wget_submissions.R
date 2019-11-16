# generate_wget_subissions.R
#
# script to generate a series of submission scripts to download the THO data
# 

urls <- readLines("urls_THO-LungCancer")

urls.list <- split(urls, 
                   ceiling(
                     seq_along(urls) / 10
                   )
)

dir.create("download_scripts/THO-LungCancer")

for (l in 1:length(urls.list)) {
  
  fileConn <- file(paste0("download_scripts//THO-LungCancer/download_THO_", 
                          l,
                          ".pbs")
                   )
  
  writeLines(c(paste0("#PBS -N download_THO_", l),
               "#PBS -A PAS1460",
               "#PBS -l walltime=10:00:00",
               "#PBS -l nodes=1:ppn=1",
               "#PBS -j oe",
               "",
               "cd /fs/scratch/PAS1460/tcc_data/THO-LungCancer"
               paste(urls.list[[l]], sep = "\n"),
               ""),
             fileConn)
  close(fileConn)
}
