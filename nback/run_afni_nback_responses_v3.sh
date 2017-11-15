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

CB0=~/project/pnc/mri/study/nback_0.1D
CB1=~/project/pnc/mri/study/nback_1.1D
CB2=~/project/pnc/mri/study/nback_2.1D



PWD_TASK=${sid}.${task}_v3
#TCSH_AFNI=afni.${sid}.${task}_test.tcsh
TCSH_AFNI=afni.${PWD_TASK}.tcsh

cd $PWD_BASE; cd $sid
echo "Running ${task} for ${sid}"

module load Python/2.7.13-foss-2016b
module load FFTW/3.3.4-gompi-2016b
module load GCC/5.4.0-2.26
module load GCCcore/5.4.0
module load GMP/6.1.1-foss-2016b
module load OpenBLAS/0.2.18-GCC-5.4.0-2.26-LAPACK-3.6.1
module load OpenMPI/1.10.3-GCC-5.4.0-2.26
module load SQLite/3.13.0-foss-2016b
module load ScaLAPACK/2.0.2-gompi-2016b-OpenBLAS-0.2.18-LAPACK-3.6.1
module load binutils/2.26-GCCcore-5.4.0
module load bzip2/1.0.6-foss-2016b
module load foss/2016b
module load gompi/2016b
module load hwloc/1.11.3-GCC-5.4.0-2.26
module load libreadline/6.3-foss-2016b
module load ncurses/6.0-foss-2016b
module load numactl/2.0.11-GCC-5.4.0-2.26
module load zlib/1.2.8-foss-2016b

custom_proc.py -subj_id ${sid} -script $TCSH_AFNI -out_dir $PWD_TASK \
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
	-regress_stim_times $CB0 $s_0_t_r $s_0_f_r $CB1 $s_1_t_r $s_1_f_r $CB2 $s_2_t_r $s_2_f_r \
	-regress_stim_labels b0 s_0_t_r s_0_f_r b1 s_1_t_r s_1_f_r b2 s_2_t_r s_2_f_r \
	-regress_local_times \
	-regress_est_blur_epits \
	-regress_est_blur_errts \
	-regress_basis_multi 'BLOCK(60,1)' 'GAM' 'GAM' 'BLOCK(60,1)' 'GAM' 'GAM' 'BLOCK(60,1)' 'GAM' 'GAM' \
	-regress_censor_outliers 0.1 \
	-regress_censor_motion 0.3 \
	-regress_reml_exec \
	-move_preproc_files \
	-regress_opts_3dD \
	-GOFORIT 7 -allzero_OK \
	-num_glt 15 \
	-gltsym 'SYM: +s_2_t_r +s_2_f_r -s_0_t_r -s_0_f_r' -glt_label 1 'c_2b_vs_0b_all' \
        -gltsym 'SYM: +s_2_t_r -s_0_t_r' -glt_label 2 'c_2b_vs_0b_target' \
        -gltsym 'SYM: +b2 -b0' -glt_label 3 'c_2b_vs_0b_noresponse' \
        -gltsym 'SYM: +s_2_t_r +s_2_f_r -s_1_t_r -s_1_f_r' -glt_label 4 'c_2b_vs_1b_all' \
        -gltsym 'SYM: +s_2_t_r -s_1_t_r' -glt_label 5 'c_2b_vs_1b_target' \
        -gltsym 'SYM: +b2 -b1' -glt_label 6 'c_2b_vs_1b_noresponse' \
        -gltsym 'SYM: +s_1_t_r +s_1_f_r -s_0_t_r -s_0_f_r' -glt_label 7 'c_1b_vs_0b_all' \
        -gltsym 'SYM: +s_1_t_r -s_0_t_r' -glt_label 8 'c_1b_vs_0b_target' \
        -gltsym 'SYM: +b1 -b0' -glt_label 9 'c_1b_vs_0b_noresponse' \
        -gltsym 'SYM: +2.0*s_2_t_r +2.0*s_2_f_r +1.0*s_1_t_r +1.0*s_1_f_r -3.0*s_0_t_r -3.0*s_0_f_r' -glt_label 10 'c_12b_vs_0b_all' \
        -gltsym 'SYM: +2.0*s_2_t_r +1.0*s_1_t_r -3.0*s_0_t_r' -glt_label 11 'c_12b_vs_0b_target' \
        -gltsym 'SYM: +2.0*s_2_f_r +1.0*s_1_f_r -3.0*s_0_f_r' -glt_label 12 'c_12b_vs_0b_foil' \
        -gltsym 'SYM: +b2 +s_2_t_r +s_2_f_r -b0 -s_0_t_r -s_0_f_r' -glt_label 13 'c_20' \
        -gltsym 'SYM: +b2 +s_2_t_r +s_2_f_r -b1 -s_1_t_r -s_1_f_r' -glt_label 14 'c_21' \
        -gltsym 'SYM: +b1 +s_1_t_r +s_1_f_r -b0 -s_0_t_r -s_0_f_r' -glt_label 15 'c_10' \
	-jobs 1 \
        -regress_opts_reml \
        -GOFORIT \
	-bash -execute 


#sed -i "42i set runs = ( 01 )" $TCSH_AFNI

#tcsh $TCSH_AFNI




