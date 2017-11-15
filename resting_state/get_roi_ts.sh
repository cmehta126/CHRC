#!/bin/bash
#SBATCH -p general -N 1 -c 1 --mem-per-cpu=5000 -t 48:00:00 --mail-type=ALL --mail-user=chintan.mehta@yale.edu

get_atlas_roi(){
	SID=$1
	ATLAS=$2
	REST_PAR=rest_BP_3mm
	cd ~/project/pnc/mri/subjects/${SID}/${SID}.${REST_PAR}
	
	[ ! -d roi_ts ] && mkdir roi_ts

	# Step 1: Warp to aparc atlases to TLRC space, Resample to 3mm
	3dNwarpApply -nwarp "anat.un.aff.qw_WARP.nii anat.un.aff.Xat.1D" -prefix roi_ts/${ATLAS} -source ../SUMA/${ATLAS}+aseg_rank.nii -master ~/abin/TT_N27+tlrc -overwrite
	3dresample -dxyz  3 3 3 -prefix roi_ts/${ATLAS}_3mm -inset roi_ts/${ATLAS}+tlrc -overwrite
	3dROIstats -quiet -mask_f2short  -mask roi_ts/${ATLAS}_3mm+tlrc "errts.${SID}.fanaticor+tlrc" > roi_ts/ts.${ATLAS}.${SID}.1D

	
	# Step 2: Get Atlas Codes:
	cd ../SUMA
	whereami -atlas ${ATLAS}+aseg_rank -show_atlas_code > ../${SID}.${REST_PAR}/roi_ts/atlas_codes.${ATLAS}.${SID}.txt

	# Step 3: Copy to results directory
	cd ~/project/pnc/mri/results/${REST_PAR}/roi_ts/
	cp ~/project/pnc/mri/subjects/${SID}/${SID}.${REST_PAR}/roi_ts/ts.${ATLAS}.${SID}.1D ts.${ATLAS}.${SID}.1D 
	cp ~/project/pnc/mri/subjects/${SID}/${SID}.${REST_PAR}/roi_ts/atlas_codes.${ATLAS}.${SID}.txt atlas_codes.${ATLAS}.${SID}.txt
	echo "complete"	
	return 0
}


get_atlas_roi $1 aparc 
get_atlas_roi $1 aparc.a2009s 
#600001103037 
