#!/usr/bin/env Rscript
#SBATCH -p general -N 1 -c 1 --mem-per-cpu=10000 -t 48:00:00 --mail-type=ALL --mail-user=chintan.mehta@yale.edu
args = commandArgs(trailingOnly=TRUE)
#Computing Intrinsic Connectivity Distribution in R:
fn.4d = args[1]
fn.gm = args[2]
fn.prefix = args[3]
pwd.results = args[4]

print("Computing Intrinsic Connectivity Distribution in R")
print("This is version 1 of ICD code. Main features are:")
print("Updates from version 0 are")
print("(*) Survival function has form exp(-(x/a)^b+c).")
print("(*) Initial guesses for parameters are (0.5, 1, 0) and boundary condition is (0, 0, -Inf)")
print("(*) There is single results file in AFNI format containing five subbricks with R2, scaled alpha, scaled beta, raw alpha, and raw_beta.")

print(paste("4d time series file is",fn.4d))
print(paste("Gray matter file is",fn.gm))
print(paste("Results file prefix is",fn.prefix))
print(paste("Results directory is", pwd.results))



make_icd = function(fn.4d, fn.gm, fn.prefix, pwd.results){
  require(oro.nifti)
  require(minpack.lm)
  require(methods)  
  # Step 1: Load 4d resting state (AFNI format) and Gray Matter Masks (NIFTI format)
  print("--------------------------------------------------------")
  print("Loading files")
  REST.4d = readAFNI(fn.4d)
  MASK.gm = readNIfTI(fn.gm)
  
  # Data arrays
  ts0 = REST.4d@.Data
  gm0 = MASK.gm@.Data
  
  nTR = dim(ts0)[4]
  nVox = prod(dim(ts0)[1:3])
  
  print(paste("4D time series has", nTR, "TRs."))
  print(paste("Each subrick in 4D time series has", nVox, "voxels."))
  print(paste("Gray matter mask has", prod(dim(gm0)[1:3]), "voxels."))
  if(any(dim(gm0) != dim(ts0)[1:3])){
    print("Errr: Dimensions of Gray matter mask and subricks in 4d time series do not match.")
    stop()
  }
  
  # Step 2: Reshape data arrays.
  print("--------------------------------------------------------")
  print("Reshaping data arrays.")
  ts1 = ts0; dim(ts1) = c(nVox, nTR)
  gm1 = gm0; dim(gm1) = c(nVox, 1)
  
  print("There is no demeaning of values in each subrick in 4d time series.")


  # Step 4: Identify voxels in Gray matter mask and restrict subricks to them.
  idx.gm = which(gm1 != 0)
  gm1 = gm1[idx.gm]
  nVox.GM = length(gm1)
  print(paste("There are", nVox.GM,"voxels that survive gray matter mask."))
  ts2 = ts1[idx.gm,]
  
  # Step 5: Remove time points that AFNI had censored:
  idx.nc = which( apply(ts2,2,norm,type="2")!=0)
  print(paste("4d time series has", length(idx.nc), "TRs after removing censored TRs."))
  ts3 = ts2[,idx.nc]
  
  # Step 6: Standardize each time series to zero mean and unit variance.
  print("Standardizing each voxel time series")
  ts4 = t(apply(ts3,1,function(s){if(sd(s)>0){s = scale(s)}; return(s)}))
  
  # Step 7: Compute ICD for each surviving voxel (indexed by rows of V4)
  # loop through rows of V4 using function compute.ICD below:
  
  print("--------------------------------------------------------")
  print("Begin ICD Computations:")
  a0 = Sys.time()
  icd0 = matrix(0,nrow=nrow(ts4),ncol=4)
  for(j in 1:nrow(ts4)){
    icd0[j,] = compute.ICD(j,ts4)
    if(floor(j/1000)==j/1000){
      print(paste(j,"voxels completed in ", round(Sys.time()-a0,1)))
      print(c(icd0[j,], icd0[j,1]^(1/icd0[j,2])))
    }
  }

  print(paste("ICD computed for full gray matter volume in ", round(Sys.time()-a0,2)))

  rho.alpha_beta = round(cor(icd0[,1], icd0[,2]),2)
  print(paste("Correlation between alpha and beta estimates over the gray matter volume was", rho.alpha_beta))


  # Step 7: Define ICD_alpha, ICD_beta, and ICD_r2 maps in AFNI format.
  q = make_ICD_maps_afni(icd0[,1], icd0[,2], icd0[,4],MASK = MASK.gm, IDX.GM = idx.gm)

  # Write maps to NIFTI file.
  setwd(pwd.results)
  fn.result = paste("icd.",fn.prefix, "+tlrc",sep="")
  
  writeAFNI(q, fname  = fn.result)
  


  print(paste("ICD maps were saved in", pwd.results))
  print(paste("AFNI BRIK/HEAD files are", fn.result,"with 5 subbricks. They are:")) 
  print("(0) coefficient of determination")
  print("(1) Alpha estimates (Scaled over mask)")
  print("(2) Beta estimates (Scaled over mask)")
  print("(3) Alpha estimates (raw)")
  print("(4) Beta estimates (raw)")
  print("--------------------------------------------------------")
  
  return(NULL) 
}

# ***************
# Residual of Surivival function 
foox = function(x,hx,hy){
  a = x[1]; b = x[2]; c = x[3]
  exp(-(1/a)*hx^b+c) - hy
}

# Jacobian for survival funciton
jac.foox = function(x, hx, hy){
  require(numDeriv)
  c(jacobian(foox,x,hx=hx,hy=hy))
}


# ******************************
compute.ICD = function(j, TS.NORM, nbreaks = 201){
  require(minpack.lm)
  # TS.NORM is matrix with rows and columns corresponding to voxels and time points. Rows are scaled to zero mean and unit variance.
  # j: index of row in TS.NORM (correponding to a given voxel) whose ICD is being evaluated.
  
  Xj = matrix(TS.NORM[j,],ncol=1)
  
  if(sd(Xj) == 0){
    out = c(0, 0, 0, 0)
  }else{
    Xej = TS.NORM[-j,]
    # Compute correlation between voxel j and other voxels.
    RHO = Xej %*% Xj / (ncol(TS.NORM)-1)
    
    # Restrict to positive correlations
    RHO.POS = RHO[which(RHO > 0)]
    
    # Make histogram.
    brks = seq(from=0, to = 1, length.out = nbreaks)
    RHO.hist = hist(RHO.POS, plot = T, breaks = brks)
    
    hx = RHO.hist$mids
    hy = 1 - cumsum(RHO.hist$density)/sum(RHO.hist$density)
    
    # Fit histogram densities to survival function.
    fit.sf = nls.lm(par = c(0.5, 1.0, 0.0), 
                    lower = c(0, 0, -Inf),
                    fn = foox, 
                    jac = jac.foox, 
                    hx = hx[-1], 
                    hy = hy[-1])
    est = fit.sf$par;
    gy = foox(est,hx[-1],hy[-1]) + hy[-1] 
    r2 = 1 - sum((gy - hy[-1])^2)/sum(hy[-1]^2)	
    out = c(est, r2)

  }
  
  names(out) = c("alpha", "beta", "constant","r2")
  return(out)
}

# ****************
make_ICD_maps_afni = function(alpha, beta, r2, MASK, IDX.GM){
  nMaps = 7
  gamma = alpha^(1/beta)
  nVox = prod(dim(MASK@.Data))
  d = array(0,c(dim(MASK@.Data), nMaps))
  d[IDX.GM] = r2
  d[IDX.GM+nVox] = scale(alpha)
  d[IDX.GM+2*nVox] = scale(beta)
  d[IDX.GM+3*nVox] = scale(gamma)
  d[IDX.GM+4*nVox] = alpha
  d[IDX.GM+5*nVox] = beta
  d[IDX.GM+6*nVox] = gamma

  require(methods)
  e = new("afni")
  
  e@.Data = d
  e@DATASET_RANK = as.integer(c(3, nMaps, rep(0,6)))
  e@DATASET_DIMENSIONS = as.integer(c(dim(MASK@.Data),0,0))
  e@TYPESTRING = "3DIM_HEAD_FUNC"
  e@SCENE_DATA = as.integer(c(2, 11, 1, rep(-999,5)))
  e@ORIENT_SPECIFIC = as.integer(c(0, 3, 4))
  e@ORIGIN = c(-79.5, -79.5, -63.5)
  e@DELTA = c(3, 3, 3)
  e@TAXIS_NUMS = as.integer()
  e@TAXIS_FLOATS= as.integer()
  e@TAXIS_OFFSETS = as.integer()
  e@IDCODE_STRING = paste("AFN_GruenLab",floor(runif(1,min=1e10,max=1e11-1)),sep="_")
  e@IDCODE_DATE = as.character(Sys.time())
  e@BYTEORDER_STRING = "LSB_FIRST" 
  e@BRICK_STATS = c(range(r2), range(scale(alpha)), range(scale(beta)), range(scale(gamma)), range(alpha), range(beta), range(gamma))
  e@BRICK_TYPES = as.integer(rep(3,dim(d)[4]))
  e@BRICK_FLOAT_FACS = as.integer(rep(0,dim(d)[4]))
  e@BRICK_LABS = "icd_r2~icd_alpha_scaled~icd_beta_scaled~icd_gamma_scaled~icd_alpha_raw~icd_beta_raw~icd_gamma_raw"
  e@HISTORY_NOTE = "ICD created in R"
  e@LABEL_1 = "zyxt"
  e@LABEL_2 = "zyxt"
  e@DATASET_NAME = "zyxt"
  return(e)
}



make_icd(fn.4d, fn.gm, fn.prefix, pwd.results)
