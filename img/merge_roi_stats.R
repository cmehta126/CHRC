#!/usr/bin/env Rscript


#system("{ export SUBJECTS_DIR=~/project/pnc/mri/subjects; export SUBJECTSFILE=~/project/pnc/mri/completed_freesurfer.txt; export SUBJECTSFILE=~/project/pnc/mri/id.txt; ls $SUBJECTS_DIR > $SUBJECTSFILE; module load Python/2.7.11-foss-2016a; FN_ASEG_STATS=/ysm-gpfs/project/cm953/pnc/mri/results/roi_stats/PNC_subcortical; FN_APARC_STATS=/ysm-gpfs/project/cm953/pnc/mri/results/roi_stats/PNC_cortical; HEMI=rh;aparcstats2table --subjectsfile $SUBJECTSFILE --skip --hemi $HEMI --meas thickness --tablefile $FN_APARC_STATS-${HEMI}_thickness.txt; aparcstats2table --subjectsfile $SUBJECTSFILE --skip --hemi $HEMI --meas area --tablefile $FN_APARC_STATS-${HEMI}_area.txt; aparcstats2table --subjectsfile $SUBJECTSFILE --skip --hemi $HEMI --meas volume --tablefile $FN_APARC_STATS-${HEMI}_volume.txt; HEMI=lh; aparcstats2table --subjectsfile $SUBJECTSFILE --skip --hemi $HEMI --meas thickness --tablefile $FN_APARC_STATS-${HEMI}_thickness.txt; aparcstats2table --subjectsfile $SUBJECTSFILE --skip --hemi $HEMI --meas area --tablefile $FN_APARC_STATS-${HEMI}_area.txt; aparcstats2table --subjectsfile $SUBJECTSFILE --skip --hemi $HEMI --meas volume --tablefile $FN_APARC_STATS-${HEMI}_volume.txt; asegstats2table --subjectsfile $SUBJECTSFILE --skip --meas volume --tablefile ${FN_ASEG_STATS}-volume.txt; FN_APARC_STATS=/ysm-gpfs/project/cm953/pnc/mri/results/roi_stats/PNC_cortical.aparc.a2009s; HEMI=rh; aparcstats2table --subjectsfile $SUBJECTSFILE --parc aparc.a2009s --skip --hemi $HEMI --meas thickness --tablefile $FN_APARC_STATS-${HEMI}_thickness.txt; aparcstats2table --subjectsfile $SUBJECTSFILE --parc aparc.a2009s --skip --hemi $HEMI --meas area --tablefile $FN_APARC_STATS-${HEMI}_area.txt; aparcstats2table --subjectsfile $SUBJECTSFILE --parc aparc.a2009s --skip --hemi $HEMI --meas volume --tablefile $FN_APARC_STATS-${HEMI}_volume.txt; HEMI=lh; aparcstats2table --subjectsfile $SUBJECTSFILE --parc aparc.a2009s --skip --hemi $HEMI --meas thickness --tablefile $FN_APARC_STATS-${HEMI}_thickness.txt; aparcstats2table --subjectsfile $SUBJECTSFILE  --parc aparc.a2009s --skip --hemi $HEMI --meas area --tablefile $FN_APARC_STATS-${HEMI}_area.txt; aparcstats2table --subjectsfile $SUBJECTSFILE  --parc aparc.a2009s --skip --hemi $HEMI --meas volume --tablefile $FN_APARC_STATS-${HEMI}_volume.txt;} &> /dev/null")



FN_ASEG_STATS = "/ysm-gpfs/project/cm953/pnc/mri/results/roi_stats/PNC_subcortical"
FN_APARC_STATS = "/ysm-gpfs/project/cm953/pnc/mri/results/roi_stats/PNC_cortical"
FN_APARC_2009_STATS = "/ysm-gpfs/project/cm953/pnc/mri/results/roi_stats/PNC_cortical.aparc.a2009s"


hemi = c("lh", "rh")
mT = paste(FN_APARC_STATS, "-", hemi, "_thickness.txt", sep = "")
mA = paste(FN_APARC_STATS, "-", hemi, "_area.txt", sep = "")
mV = paste(FN_APARC_STATS, "-", hemi, "_volume.txt", sep = "")
sT = paste(FN_APARC_2009_STATS, "-", hemi, "_thickness.txt", sep = "")
sA = paste(FN_APARC_2009_STATS, "-", hemi, "_area.txt", sep = "")
sV = paste(FN_APARC_2009_STATS, "-", hemi, "_volume.txt", sep = "")

mS = paste(FN_ASEG_STATS, "-volume.txt", sep = "")

m0 = c(mT, mA, mV, sT, sA, sV, mS)


X0 = read.table(m0[1], header = T, row.names = 1)
for(fn in m0[-1]){
	X1 = read.table(fn, header = T, row.names = 1)
	print(fn)
	print(colnames(X1)[1])
	X1 = X1[rownames(X0),]
	X0[,colnames(X1)] = NA
	X0[,colnames(X1)] = X1
}

idx_total_area = grep("WhiteSurfArea", colnames(X0))
X0$total_area = apply(X0[,idx_total_area],1,sum)

cn = colnames(X0)
X0$Subj = rownames(X0)
X0 = X0[,c("Subj", cn)] 


fn_out = "/ysm-gpfs/project/cm953/data/PNC_roi_master.txt"
write.table(X0, file = fn_out, col.names = T, row.names = F, quote = F)


system(paste("echo \'There are ROI summary statisics for", nrow(X0), "subjects.\'"))
system(paste("echo \'ROI summary statisics are located in:\'"));
system(paste("echo \'", fn_out, "\'"))

