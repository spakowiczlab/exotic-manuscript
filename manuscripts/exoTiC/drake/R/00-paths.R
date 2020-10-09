###############################
### Locate the $HOME directory
source_paths <- function(){
  home <- Sys.getenv("HOME", unset = NA)
  if (is.na(home)) stop("Cannot find 'HOME' from environment variable s.")
  
  ### Find the JSON path information in the appropriate directory.
  jinfo <- file.path(home, "Documents","repos", "exoTCC","exoTCC.json")
  if (!file.exists(jinfo)) stop("Cannot locate file: '", jinfo, "'.\n", sep='')
  ### parse it
  library(rjson)
  temp <- fromJSON(file = file_in(jinfo))
  paths <- temp$paths
  detach("package:rjson")
  ### clean up
  return(paths)
}
