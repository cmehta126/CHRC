#!/bin/bash
#SBATCH -p general -N 1 -c 1 --mem-per-cpu=6000 -t 48:00:00 --mail-type=ALL --mail-user=chintan.mehta@yale.edu

TASK=BOLD_emotionid

SID=$1
PWD_NIFTI=~/scratch60/pnc/nifti
PWD_BASE=$PNC_SUBJECTS
STIMULUS_FILES=/ysm-gpfs/home/cm953/scratch60/pnc/mri/study/emoid_*.1D

STIM_H=/ysm-gpfs/home/cm953/scratch60/pnc/mri/study/emo_happy.1D
STIM_S=/ysm-gpfs/home/cm953/scratch60/pnc/mri/study/emo_sad.1D
STIM_A=/ysm-gpfs/home/cm953/scratch60/pnc/mri/study/emo_angry.1D
STIM_F=/ysm-gpfs/home/cm953/scratch60/pnc/mri/study/emo_fear.1D
STIM_N=/ysm-gpfs/home/cm953/scratch60/pnc/mri/study/emo_neutral.1D


module load Python/2.7.11-foss-2016a

FN_NIFTI=${PWD_NIFTI}/${SID}.${TASK}.nii.gz; 
TCSH_AFNI=afni.${SID}.${TASK}.tcsh
PWD_TASK=${SID}.${TASK}

cd $PWD_BASE; cd $SID
echo "Running ${TASK} for ${SID}"
echo $PWD_BASE
module load Python/2.7.11-foss-2016a

[ -d $PWD_TASK ] && rm -rf $PWD_TASK
[ -e $TCSH_AFNI ] && rm $TCSH_AFNI
[ -e output.${TCSH_AFNI} ] && rm output.${TCSH_AFNI}














































