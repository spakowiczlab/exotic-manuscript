voom_snm_normalization_expr <- function(qcMetadata, qcData, biovars, adjvars){
  set.seed(112358)
  
  # Set up design matrix
  covDesignNorm <- model.matrix(as.formula(paste0("~0 + ", paste(adjvars, collapse = " + "))),
                                data = qcMetadata)
  
  # Check row dimensions
  dim(covDesignNorm)[1] == dim(qcData)[1]
  
  # print(colnames(covDesignNorm))
  # The following corrects for column names that are incompatible with downstream processing
  # colnames(covDesignNorm) <- gsub('([[:punct:]])|\\s+','',colnames(covDesignNorm))
  # print(colnames(covDesignNorm))
  
  # Set up counts matrix
  counts <- t(qcData) # DGEList object from a table of counts (rows=features, columns=samples)
  
  # Quantile normalize and plug into voom
  dge <- DGEList(counts = counts)
  vdge <- voom(dge,
               design = covDesignNorm, 
               # plot = TRUE, save.plot = TRUE, 
                normalize.method="quantile")
  
  # List biological and normalization variables in model matrices
  bio.var <- model.matrix(as.formula(paste0("~", paste(biovars, collapse = "+"))),
                          data=qcMetadata)
  
  adj.var <- model.matrix(as.formula(paste0("~", paste(adjvars, collapse = "+"))),
                          data=qcMetadata)
  
  # colnames(bio.var) <- gsub('([[:punct:]])|\\s+','',colnames(bio.var))
  # colnames(adj.var) <- gsub('([[:punct:]])|\\s+','',colnames(adj.var))
  print(dim(adj.var))
  print(dim(bio.var))
  print(dim(t(vdge$E)))
  print(dim(covDesignNorm))
  
  snmDataObjOnly <- snm(raw.dat = vdge$E, 
                        bio.var = bio.var, 
                        adj.var = adj.var, 
                        rm.adj=TRUE,
                        verbose = TRUE,
                        diagnose = TRUE)
  snmData <- t(snmDataObjOnly$norm.dat) %>%
    as.data.frame()
  snmData$sample <- qcMetadata$sample
  return(snmData)
}
