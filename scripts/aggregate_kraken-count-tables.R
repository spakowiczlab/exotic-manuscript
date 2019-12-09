library(dplyr)

# Grab all of the aggregated counts files
files <- list.files(path = "/fs/scratch/PAS1479/data", 
                    pattern = "aggcounts", 
                      )

# Read in all files to a list
x <- lapply(files, function(x) read.table(x, 
                                          sep = "\t", 
                                          header = TRUE,
                                          stringsAsFactors = TRUE)
)

# Create a dataframe
df <- dplyr::bind_rows(x)

# Set NA to 0
df.0 <- data.frame(
  apply(df, 2, function(x) ifelse(is.na(x), 0, x)
  )
)

# Write output as csv
write.csv(df.0, 
          file = "aggcounts_all.csv",
          row.names = FALSE)
