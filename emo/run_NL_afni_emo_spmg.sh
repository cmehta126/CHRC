#!/bin/bash
#SBATCH -p general -N 1 -c 1 --mem-per-cpu=6000 -t 48:00:00 --mail-type=ALL --mail-user=chintan.mehta@yale.edu

TASK=BOLD_emotionid_NL

SID=$1
PWD_NIFTI=~/scratch60/pnc/nifti
PWD_BASE=$PNC_SUBJECTS
STIMULUS_FILES=/ysm-gpfs/home/cm953/scratch60/pnc/mri/study/emoid_*.1D

STIM_H=/ysm-gpfs/home/cm953/scratch60/pnc/mri/study/emo_happy.1D
STIM_S=/ysm-gpfs/home/cm953/scratch60/pnc/mri/study/emo_sad.1D
STIM_A=/ysm-gpfs/home/cm953/scratch60/pnc/mri/study/emo_angry.1D
STIM_F=/ysm-gpfs/home/cm953/scratch60/pnc/mri/study/emo_fear.1D
STIM_N=/ysm-gpfs/home/cm953/scratch60/pnc/mri/study/emo_neutral.1D

source /ysm-gpfs/home/cm953/.bashrc

module load Python/2.7.11-foss-2016a

FN_NIFTI=${PWD_NIFTI}/${SID}.${TASK}.nii.gz; 
TCSH_AFNI=afni.${SID}.${TASK}.tcsh
PWD_TASK=${SID}.${TASK}

source 

cd $PWD_BASE; cd $SID
echo "Running ${TASK} for ${SID}"
echo $PWD_BASE
module load Python/2.7.11-foss-2016a

[ -d $PWD_TASK ] && rm -rf $PWD_TASK
[ -e $TCSH_AFNI ] && rm $TCSH_AFNI
[ -e output.${TCSH_AFNI} ] && rm output.${TCSH_AFNI}



afni_proc.py -subj_id ${SID} -script $TCSH_AFNI -out_dir $PWD_TASK \
	-dsets $FN_NIFTI  \
	-blocks tshift align tlrc volreg blur mask scale regress \
	-copy_anat SUMA/${SID}_SurfVol.nii \
	-anat_has_skull yes \
        -tcat_remove_first_trs 4 \
        -volreg_align_e2a -volreg_tlrc_warp \
        -tlrc_NL_warp \
        -align_opts_aea -big_move \
        -tshift_opts_ts -tpattern alt+z2 \
        -blur_size 6 -volreg_align_to first  \
	-regress_stim_times $STIM_S $STIM_A $STIM_F $STIM_N $STIM_H \
	-regress_stim_labels sad angry fear neutral happy \
	-regress_local_times \
	-regress_est_blur_epits \
	-regress_est_blur_errts \
	-regress_basis 'SPMG2(5.5)' \
	-regress_censor_outliers 0.1 \
	-regress_censor_motion 0.2 \
	-regress_reml_exec \
	-regress_opts_3dD \
	-num_glt 15 \
	-gltsym 'SYM: +happy -neutral' -glt_label 1 'happy-neutral' \
        -gltsym 'SYM: +sad -neutral' -glt_label 2 'sad-neutral' \
        -gltsym 'SYM: +angry -neutral' -glt_label 3 'angry-neutral' \
        -gltsym 'SYM: +fear -neutral' -glt_label 4 'fear-neutral' \
        -gltsym 'SYM: +happy +sad +angry +fear -4*neutral' -glt_label 5 'allEmotion-neutral' \
        -gltsym 'SYM: +sad +angry +fear -3*neutral' -glt_label 6 'negEmotion-neutral' \
        -gltsym 'SYM: +sad +angry +fear -3*happy' -glt_label 7 'negEmotion-happy' \
	-gltsym 'SYM: +angry +fear -happy -sad' -glt_label 8 'threatEmotion' \
	-jobs 1 -rout \
	-regress_run_clustsim yes \
	-remove_preproc_files \
	-bash -execute 

if (( $? == 0 )); then
	echo $SID >> ~/scratch60/pnc/status/completed_emo.txt
else
	echo $SID >> ~/scratch60/pnc/status/incomplete_emo.txt
fi

echo "Completed AFNI processing for ${SID}"

