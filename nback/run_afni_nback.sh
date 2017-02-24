#!/bin/bash
#SBATCH -p general -N 1 -c 1 --mem-per-cpu=6000 -t 48:00:00 --mail-type=ALL --mail-user=chintan.mehta@yale.edu

TASK=BOLD_nback

SID=$1
PWD_NIFTI=$2
PWD_BASE=$3
STIMULUS_FILES=/ysm-gpfs/home/cm953/project/pnc/mri/study/nback_*.1D

module load Python/2.7.11-foss-2016a

FN_NIFTI=${PWD_NIFTI}/${SID}.${TASK}.nii.gz; 
TCSH_AFNI=afni.${SID}.${TASK}.tcsh
PWD_TASK=${SID}.${TASK}

cd $PWD_BASE; cd $SID
echo "Running ${TASK} for ${SID}"
module load Python/2.7.11-foss-2016a

afni_proc.py -subj_id ${SID} -script $TCSH_AFNI -out_dir $PWD_TASK \
	-dsets $FN_NIFTI  \
	-blocks tshift align tlrc volreg blur mask scale regress \
	-copy_anat SUMA/${SID}_SurfVol.nii \
	-anat_has_skull yes \
	-tcat_remove_first_trs 4 \
	-volreg_align_e2a -volreg_tlrc_warp \
	-tlrc_opts_at -init_xform AUTO_CENTER \
	-align_opts_aea -big_move \
	-tshift_opts_ts -tpattern alt+z2 \
	-blur_size 8 -volreg_align_to first  \
	-regress_stim_times $STIMULUS_FILES \
	-regress_stim_labels b0 b1 b2 \
	-regress_local_times \
	-regress_est_blur_epits \
	-regress_est_blur_errts \
	-regress_basis 'BLOCK(60,1)' \
	-regress_censor_outliers 0.1 \
	-regress_censor_motion 0.3 \
	-regress_reml_exec \
	-regress_opts_3dD \
	-num_glt 15 \
	-gltsym 'SYM: +b2 -b0' -glt_label 1 'contrast_20' \
	-gltsym 'SYM: +b1 -b0' -glt_label 2 'contrast_10' \
	-gltsym 'SYM: +b2 -b1' -glt_label 3 'contrast_21' \
	-jobs 1 -rout \
	-bash -execute &

echo "Completed AFNI processing for ${SID}"
