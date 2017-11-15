#!/bin/bash
#SBATCH -p general -N 1 -c 1 --mem-per-cpu=5000 -t 48:00:00 --mail-type=ALL --mail-user=chintan.mehta@yale.edu



make_seed_correlation () {
	SID=$1
	ROI=$2
		
	FN_GM_MASK=/ysm-gpfs/home/cm953/project/code/masks/TT_N27_GM_3mm.nii

	
	# Step 0: collecting ROI code in atlas.
	cd ~/project/pnc/mri/subjects/${SID}/SUMA
	whereami -atlas aparc+aseg_rank -show_atlas_code | grep -i $ROI | cut -d':' -f3 > tmp.txt 
	readarray roi_id < tmp.txt
	
	# Step 1
	# Extracting mask for ROI.
	cd ~/project/pnc/mri/subjects/${SID}/${SID}.rest_BP_3mm
	Q1="3dcalc -a ../SUMA/aparc+aseg_rank.nii -datum byte -prefix seed/${ROI} -expr 'amongst(a, ${roi_id[0]})'"
	eval $Q1

	# Step 2: Warp to tlrc space, Resample to 3mm
	3dNwarpApply -nwarp "anat.un.aff.qw_WARP.nii anat.un.aff.Xat.1D" -prefix seed/${ROI} -source seed/${ROI}+orig -master ~/abin/TT_N27+tlrc -overwrite
	3dresample -dxyz  3 3 3 -prefix seed/${ROI}_3mm -inset seed/${ROI}+tlrc -overwrite

	# Step 3: Make 1D time series
	3dmaskave -quiet -mask seed/${ROI}_3mm+tlrc errts.${SID}.fanaticor+tlrc > seed/ideal.${ROI}+tlrc.1D
	echo "Created ideal file."
		
	# Step 4: Making Seed-based correlation.
	#3dfim+ -input errts.${SID}.fanaticor+tlrc -mask $FN_GM_MASK -ideal_file seed/ideal.${ROI}+tlrc.1D -out Correlation -overwrite -bucket extra/Corr_seed.${SUFFIX}
	
	echo "Created time series correlation map."
	#3dcalc -a extra/Corr_seed.${SUFFIX}+tlrc -expr 'atanh(a)' -float -overwrite -prefix $FN_OUT
	echo "Fisher transformation of correlation map is in ${FN_OUT}."

	echo "Complete."
	
	3drefit -sublabel 0 'lh-posteriorcingulate' zcorr_seed.lh-posteriorcingulate+tlrc.
	3dbucket zcorr_seed.lh-posteriorcingulate+tlrc -dry -aglueto zcorr_seed
	return 0
}


REST_PAR=$1
SID=$2
REST_PAR=rest_BP_3mm
SID=600054124128
ROI=lh-posteriorcingulate

cd ~/project/pnc/mri/subjects/${SID}/${SID}.${REST_PAR}
[ ! -d seed ] && mkdir seed
make_seed_correlation $SID $ROI














