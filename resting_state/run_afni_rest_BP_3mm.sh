#!/bin/bash
#SBATCH -p general -N 1 -c 1 --mem-per-cpu=6000 -t 48:00:00 --mail-type=ALL --mail-user=chintan.mehta@yale.edu

PWD_BASE=$3
SID=$1
PWD_NIFTI=$2
setting=rest_BP_3mm

module load Python/2.7.11-foss-2016a

FN_NIFTI=${PWD_NIFTI}/${SID}.BOLD_rest.nii.gz
cd ${PWD_BASE}/${SID}

# Setting 4: 3mm motion correction, Band-pass filtering 0.01, 0.1
afni_proc.py -subj_id ${SID} \
	-script afni_${SID}_${setting} -out_dir ${SID}.${setting} \
	-blocks despike tshift align tlrc volreg blur mask regress \
	-copy_anat SUMA/${SID}_SurfVol.nii \
	-anat_follower_ROI aaseg anat SUMA/aparc.a2009s+aseg.nii \
	-anat_follower_ROI aeseg epi  SUMA/aparc.a2009s+aseg.nii \
	-anat_follower_ROI FSvent epi SUMA/${SID}_vent.nii \
	-anat_follower_ROI FSWe epi SUMA/${SID}_WM.nii \
	-anat_follower_erode FSvent FSWe \
	-dsets $FN_NIFTI \
	-tcat_remove_first_trs 6 \
	-tshift_opts_ts -tpattern alt+z2 \
	-tlrc_NL_warp \
	-volreg_align_to MIN_OUTLIER \
	-volreg_align_e2a \
	-volreg_tlrc_warp \
	-blur_size 6 \
	-regress_bandpass 0.01 0.1 \
	-regress_ROI_PC FSvent 3 \
	-regress_make_corr_vols aeseg FSvent \
	-regress_anaticor_fast \
	-regress_anaticor_label FSWe \
	-regress_censor_motion 0.3 \
	-regress_censor_outliers 0.1 \
	-regress_apply_mot_types demean deriv \
	-regress_est_blur_epits \
	-regress_est_blur_errts \
	-regress_run_clustsim yes \
	-remove_preproc_files \
	-bash -execute
	
