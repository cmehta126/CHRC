#!/usr/bin/env Rscript
#SBATCH -p general -N 1 -c 1 --mem-per-cpu=10000 -t 48:00:00 --mail-type=ALL --mail-user=chintan.mehta@yale.edu
args = commandArgs(trailingOnly=TRUE)
#Computing Intrinsic Connectivity Distribution in R:
fn.4d = args[1]
fn.gm = args[2]
fn.prefix = args[3]
pwd.results = args[4]

print(paste("4d time series file is",fn.4d))
print(paste("Gray matter file is",fn.gm))
print(paste("Results file prefix is",fn.prefix))
print(paste("Results directory is", pwd.results))

make_icd = function(fn.4d, fn.gm, fn.prefix, pwd.results, gsr=F){
  require(oro.nifti)
  require(minpack.lm)
  
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
  
  # Step3: If gsr=T, demean each values at each subrick.
  #if(gsr){
  #  print("Removing mean from each subrick in 4d time series.")
  #  ts1 = apply(ts1,2,function(s){s - mean(s)})
  #}else{
    print("There is no demeaning of values in each subrick in 4d time series.")
  #}
  
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
    if(floor(j/100)==j/100){
      print(paste(j,"voxels completed in ", round(Sys.time()-a0,1)))
      print(icd0[j,])
    }
  }

  print(paste("ICD computed for full gray matter volume in ", round(Sys.time()-a0,2)))
  
  
  
  # Step 7: Define ICD_alpha, ICD_beta, and ICD_r2 maps in Nifti format.
  map_alpha = make_ICD_maps(icd0[,1], gm0, gm1, idx.gm, MASK.gm)
  map_beta = make_ICD_maps(icd0[,2], gm0, gm1, idx.gm, MASK.gm)
  map_r2 = make_ICD_maps(icd0[,4], gm0, gm1, idx.gm, MASK.gm) 

  # Write maps to NIFTI file.
  setwd(pwd.results)
  fn.a = paste("icd_alpha",fn.prefix, sep=".")
  fn.b = paste("icd_beta",fn.prefix, sep = ".")
  fn.r = paste("icd_r2", fn.prefix, sep = ".")

  writeNIfTI(map_alpha, filename = fn.a, gzipped = T)
  writeNIfTI(map_beta, filename = fn.b, gzipped = T)
  writeNIfTI(map_r2, filename = fn.r, gzipped = T)	

  print(paste("ICD maps were saved in", pwd.results))
  print(paste("ICD-alpha NIFTI is", fn.a)) 
  print(paste("ICD-beta NIFTI is", fn.b))
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
    fit.sf = nls.lm(par = rep(0.5,3), 
                    lower = c(0,0,-Inf),
                    fn = foox, 
                    jac = jac.foox, 
                    hx = hx[-1], 
                    hy = hy[-1])
    out = c(fit.sf$par, 1 - fit.sf$deviance/sum(hy[-1]^2))

  }
  
  names(out) = c("alpha", "beta", "constant","r2")
  return(out)
}

# ****************
make_ICD_maps = function(e0, GM0, GM1, IDX.GM, MASK){
  e1 = (e0-min(e0))/diff(range(e0))
  e1 = scale(e1)
  a = GM0 
  a[IDX.GM] = e1
  a[-IDX.GM] = 0
  dim(a) = dim(GM0)
  MASK@.Data = a
  MASK@cal_max = max(a)*1.01
  MASK@cal_min = min(a)
  MASK@glmax = max(a)*1.01
  MASK@glmin = min(a)
  
  MASK@bitpix = 64
  MASK@datatype = 64
  MASK@scl_slope = 1
  return(MASK)
}

make_icd(fn.4d, fn.gm, fn.prefix, pwd.results, gsr=T)
