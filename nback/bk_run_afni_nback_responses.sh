#!/bin/bash
#SBATCH -N 1 -c 1 --mem-per-cpu=8000 -t 48:00:00 --mail-type=ALL --mail-user=chintan.mehta@yale.edu

task=fractal_nback
sid=$1
fn_nifti=~/scratch60/data/nifti/${sid}.${task}.nii.gz


PWD_BASE=$PNC_SUBJECTS

stim_pwd=~/scratch60/data/stim_files
s_0_f_n=${stim_pwd}/${sid}.cond_0back.foil.no_response.txt    
s_1_f_n=${stim_pwd}/${sid}.cond_1back.foil.no_response.txt
s_2_f_n=${stim_pwd}/${sid}.cond_2back.foil.no_response.txt
s_0_f_r=${stim_pwd}/${sid}.cond_0back.foil.response.txt
s_1_f_r=${stim_pwd}/${sid}.cond_1back.foil.response.txt
s_2_f_r=${stim_pwd}/${sid}.cond_2back.foil.response.txt

s_0_t_n=${stim_pwd}/${sid}.cond_0back.target.no_response.txt
s_1_t_n=${stim_pwd}/${sid}.cond_1back.target.no_response.txt
s_2_t_n=${stim_pwd}/${sid}.cond_2back.target.no_response.txt
s_0_t_r=${stim_pwd}/${sid}.cond_0back.target.response.txt
s_1_t_r=${stim_pwd}/${sid}.cond_1back.target.response.txt
s_2_t_r=${stim_pwd}/${sid}.cond_2back.target.response.txt

cat $s_2_t_r



TCSH_AFNI=afni.${sid}.${task}_test.tcsh
PWD_TASK=${sid}.${task}_test

cd $PWD_BASE; cd $sid
echo "Running ${task} for ${sid}"
module load Python/2.7.11-foss-2016a

afni_proc.py -subj_id ${sid} -script $TCSH_AFNI -out_dir $PWD_TASK \
	-dsets $fn_nifti  \
	-blocks tshift align tlrc volreg blur mask scale regress \
	-copy_anat SUMA/${sid}_SurfVol.nii \
	-anat_has_skull yes \
	-tcat_remove_first_trs 4 \
	-volreg_align_e2a -volreg_tlrc_warp \
	-tlrc_NL_warp \
        -align_opts_aea -big_move \
        -tshift_opts_ts -tpattern alt+z2 \
        -blur_size 6 -volreg_align_to first  \
	-regress_stim_times $s_0_t_r $s_0_t_n $s_0_f_r $s_0_f_n $s_1_t_r $s_1_t_n $s_1_f_r $s_1_f_n $s_2_t_r $s_2_t_n $s_2_f_r $s_2_f_n \
	-regress_stim_labels cond_0back_target_response cond_0back_target_noresponse cond_0back_foil_response cond_0back_foil_noresponse cond_1back_target_response cond_1back_target_noresponse cond_1back_foil_response cond_1back_foil_noresponse cond_2back_target_response cond_2back_target_noresponse cond_2back_foil_response cond_2back_foil_noresponse \
	-regress_local_times \
	-regress_est_blur_epits \
	-regress_est_blur_errts \
	-regress_basis 'GAM(3)' \
	-regress_censor_outliers 0.1 \
	-regress_censor_motion 0.3 \
	-regress_reml_exec \
	-regress_opts_3dD \
	-GOFORIT 7 -allzero_OK \
	-num_glt 12 \
	-gltsym 'SYM: +cond_1back_target_response -cond_0back_target_response' -glt_label 1 'contrast_cond_20_target_response' \
	-gltsym 'SYM: +cond_1back_target_response -cond_1back_target_noresponse' -glt_label 2 'contrast_response_2back_target' \
	-gltsym 'SYM: +cond_0back_target_response -cond_0back_target_noresponse' -glt_label 3 'contrast_response_0back_target' \
	-jobs 1 -rout \
	-bash -execute 


echo "Completed AFNI processing for ${sid}"

