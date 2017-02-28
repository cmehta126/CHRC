#!/bin/bash
#SBATCH -p general -N 1 -c 1 --mem-per-cpu=6000 -t 48:00:00 --mail-type=ALL --mail-user=chintan.mehta@yale.edu

TASK=BOLD_nback
PWD_TASK_NAME=BOLD_nback_nl


SID=$1
PWD_NIFTI=$2
PWD_BASE=$3
STIMULUS_FILES=/ysm-gpfs/home/cm953/project/pnc/mri/study/nback_*.1D

module load Python/2.7.11-foss-2016a

FN_NIFTI=${PWD_NIFTI}/${SID}.${TASK}.nii.gz; 
TCSH_AFNI=afni.${SID}.${PWD_TASK_NAME}.tcsh
PWD_TASK=${SID}.${PWD_TASK_NAME}

cd $PWD_BASE; cd $SID
echo "Running ${TASK} for ${SID}"
module load Python/2.7.11-foss-2016a

rm -rf $PWD_TASK
if (( $? == 0 )); then
	echo "done"
fi


