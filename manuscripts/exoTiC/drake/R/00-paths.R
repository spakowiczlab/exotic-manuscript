###############################
### Locate the $HOME directory
home <- Sys.getenv("HOME", unset = NA)
if (is.na(home)) stop("Cannot find 'HOME' from environment variable s.")

### Find the JSON path information in the appropriate directory.
jinfo <- file.path(home, "Documents","repos", "exoTCC","exoTCC.json")
if (!file.exists(jinfo)) stop("Cannot locate file: '", jinfo, "'.\n", sep='')
### parse it
library(rjson)
temp <- fromJSON(file = jinfo)
paths <- temp$paths
detach("package:rjson")
### clean up
rm(home, jinfo, temp)
