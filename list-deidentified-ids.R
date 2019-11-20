# list-dedentified-ids.R
#
# Dan Spakowicz
# 2019-11-19
# Grabs the ids of all the files 

library(dplyr)

# Find url lists
files <- list.files(path = "download_urls/cufflinks/", full.names = TRUE)

# Read in urls 
urls <- lapply(files, readLines)
names(urls) <- gsub(".*_cuff_(.*).txt", "\\1", files)


# Create object to capture output
out <- list()

# Grab each cancer & id 
for (n in names(urls)) {
  out[[n]] <- data.frame(cancer = n,
                         id = gsub(".*/(SL.*)_cufflinks.*", "\\1", urls[[n]]),
                         stringsAsFactors = FALSE
                         )
}

# Merge into single dataframe
dfout <- bind_rows(out)

# Write output
write.csv(x = dfout,
          file = "exotcc_deidentified-ids.csv",
          row.names = FALSE)
