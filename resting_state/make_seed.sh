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
	rm tmp.txt	

	# Step 1
	# Extracting mask for ROI.
	cd ~/project/pnc/mri/subjects/${SID}/${SID}.rest_BP_3mm
	Q1="3dcalc -a ../SUMA/aparc+aseg_rank.nii -datum byte -overwrite -prefix masks/${ROI} -expr 'amongst(a, ${roi_id[0]})'"
	eval $Q1

	# Step 2: Warp to tlrc space, Resample to 3mm
	3dNwarpApply -nwarp "anat.un.aff.qw_WARP.nii anat.un.aff.Xat.1D" -prefix masks/${ROI} -source masks/${ROI}+orig -master ~/abin/TT_N27+tlrc -overwrite
	3dresample -dxyz  3 3 3 -prefix masks/${ROI}_3mm -inset masks/${ROI}+tlrc -overwrite
		

	# Step 3: Make 1D time series
	3dmaskave -quiet -mask masks/${ROI}_3mm+tlrc errts.${SID}.fanaticor+tlrc > seed/ideal.${ROI}+tlrc.1D
	echo "Created ideal file."
	

	# Step 4: Making Seed-based correlation.
	3dfim+ -input errts.${SID}.fanaticor+tlrc -mask $FN_GM_MASK -ideal_file seed/ideal.${ROI}+tlrc.1D -out Correlation -overwrite -bucket seed/tmp.corr_seed 
	Q2="3drefit -sublabel 0 '${ROI}' seed/tmp.corr_seed+tlrc"
	eval $Q2
	3dcalc -a seed/tmp.corr_seed+tlrc -expr 'atanh(a)' -float -prefix seed/tmp.zcorr_seed -overwrite

	3dbucket seed/tmp.zcorr_seed+tlrc -aglueto seed/zcorr_seed+tlrc
        3dbucket seed/tmp.corr_seed+tlrc -aglueto seed/corr_seed+tlrc



	echo "Created time series correlation map."
	#3dcalc -a seed/corr_seed.${ROI}+tlrc -expr 'atanh(a)' -float -prefix seed/zcorr_seed.${ROI} 
	echo "Fisher transformation of correlation map is in ${FN_OUT}."

	echo "Complete."
		
	return 0
}



SID=$1
REST_PAR=rest_BP_3mm

ROI=lh-posteriorcingulate

cd ~/project/pnc/mri/subjects/${SID}/${SID}.${REST_PAR}
[ ! -d seed ] && mkdir seed
make_seed_correlation $SID lh-inferiortemporal
make_seed_correlation $SID rh-inferiortemporal
make_seed_correlation $SID lh-inferiorparietal
#make_seed_correlation $SID rh-inferiorparietal


