# generate_wget_subissions_cufflinks.R
#
# script to generate a series of submission scripts to download all cufflinks 
# data
# 

# Find url lists
files <- list.files(path = "download_urls/cufflinks/", full.names = TRUE)

# Read in urls 
urls <- lapply(files, readLines)
names(urls) <- gsub(".*_cuff_(.*).txt", "\\1", files)

# Add wget command
wget.urls <- lapply(urls, function(x) gsub("^(.*)", "wget \\1", x))

# Split into lists of <= 20 lines
urls.lists <- lapply(wget.urls, function(x) split(x, 
                                                  ceiling(
                                                    seq_along(x) / 20
                                                  )
)
)

# Create directories for each cancer
for (n in names(urls)) {
  dir.create(paste0("download_scripts/cufflinks/", n), recursive = TRUE)
}


# Append submission instructions to a file of each list
for (n in names(urls.lists)) {
  
  for (l in 1:length(urls.lists[[n]])) {
    
    fileConn <- file(paste0("download_scripts/cufflinks/", n, 
                            "/download_", n, "_", l, ".pbs")
                   )
  
  writeLines(c(paste0("#PBS -N download_",n, "_", l),
                            "#PBS -A PAS1460",
                            "#PBS -l walltime=10:00:00",
                            "#PBS -l nodes=1:ppn=1",
                            "#PBS -j oe",
                            "",
                            paste0("cd /fs/scratch/PAS1460/tcc_data/cufflinks/", n),
                            paste(unlist(urls.lists[[n]][l]), sep = "\n"),
                            ""),
                     fileConn)
    close(fileConn)
  }
}
