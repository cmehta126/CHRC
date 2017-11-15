#!/bin/bash
#SBATCH -p general -N 1 -c 1 --mem-per-cpu=6000 -t 48:00:00 --mail-type=ALL --mail-user=chintan.mehta@yale.edu


PWD_BASE=$1
PWD_NIFTI=$2
SID=$2
TASK=$3

FN_NIFTI=${PWD_NIFTI}/${SID}.${TASK}.nii.gz
FN_LOG=${PWD_NIFTI}/${SID}.${TASK}_presentation.log
TCSH_AFNI=afni.${SID}.${TASK}.tcsh
PWD_TASK=${SID}.${TASK}

cd $PWD_BASE
echo "Subject $aSub: "
if [ -e $SID/${PWD_TASK} ]; then
	echo "Running ${TASK}"
	cd $SID
	afni_proc.py -subj_id ${aSub} -script $TCSH_AFNI -out_dir $PWD_TASK \
	-dsets func_pid/*.nii.gz  \
	-blocks tshift align tlrc volreg blur mask scale regress \
	-copy_anat anat/*MPRAGE*.nii.gz \
	-anat_has_skull yes \
	-tcat_remove_first_trs 4 \
	-volreg_align_e2a -volreg_tlrc_warp \
	-tlrc_opts_at -init_xform AUTO_CENTER \
	-align_opts_aea -big_move \
	-tshift_opts_ts -tpattern alt+z2 \
	-blur_size 8 -volreg_align_to first  \
	-regress_stim_times stim_times/stim_times_pid/timings_cond* \
	-regress_stim_labels pic_cue vis_mismatch aud_mismatch vis_match aud_match \
	-regress_local_times \
	-regress_est_blur_epits \
	-regress_est_blur_errts \
	-regress_basis 'GAM' \
	-regress_censor_outliers 0.1 \
	-regress_censor_motion 0.3 \
	-regress_reml_exec \
	-regress_opts_3dD \
	-num_glt 15 \
	-gltsym 'SYM: +vis_mismatch' -glt_label 1 'vis_word_mis' \
	-gltsym 'SYM: +aud_mismatch' -glt_label 2 'aud_word_mis' \
	-gltsym 'SYM: +vis_match' -glt_label 3 'vis_match' \
	-gltsym 'SYM: +aud_match' -glt_label 4 'aud_match' \
	-gltsym 'SYM: +pic_cue' -glt_label 5 'pic_cue' \
	-gltsym 'SYM: +vis_match +aud_match' -glt_label 6 'all_word_match' \
	-gltsym 'SYM: +vis_mismatch +aud_mismatch' -glt_label 7 'all_word_mismatch' \
	-jobs 12 -rout \
	-bash -execute
	
	cd ../
fi

if [ ! -e $aSub/qc ]; then
	echo "Running QC"
	./gen_qc.sh $aSub
fi