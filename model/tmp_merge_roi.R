FN_ASEG_STATS = "~/results/PNC_subcortical"
FN_APARC_STATS = "~/results/PNC_cortical"

hemi = c("lh", "rh")
mT = paste(FN_APARC_STATS, "-", hemi, "_thickness.txt", sep = "")
mA = paste(FN_APARC_STATS, "-", hemi, "_area.txt", sep = "")
mV = paste(FN_APARC_STATS, "-", hemi, "_volume.txt", sep = "")
mS = paste(FN_ASEG_STATS, "-volume.txt", sep = "")

m0 = c(mS, mT, mA, mV)

X0 = read.table(m0[1], header = T, row.names = 1)
for(fn in m0[-1]){
  X1 = read.table(fn, header = T, row.names = 1)
  X1 = X1[rownames(X0),]
  X0[,colnames(X1)] = NA
  X0[,colnames(X1)] = X1
}

idx_total_area = grep("WhiteSurfArea", colnames(X0))
X0$total_area = apply(X0[,idx_total_area],1,sum)

idx_total_lh_volume = grep("WhiteSurfArea", colnames(X0))


q1 = X0$CortexVol
#q2 = apply(X0[,colnames(X0)[grep("volume", colnames(X0))]],1,sum)
q2 = X0$EstimatedTotalIntraCranialVol
plot(q1,q2); abline(0,1,col=4)



X0$total_area = apply(X0[,idx_total_area],1,sum)

cn = colnames(X0)
X0$sid = rownames(X0)
