#!/bin/bash
#SBATCH -p gpu -N 1 -c 1 -t 24:00:00 --gres=gpu:1 --gres-flags=enforce-binding --mem-per-cpu=20000
subj=$1

module load CUDA/7.5.18
source ${FSLDIR}/etc/fslconf/fsl.sh

cd ~/scratch60/pnc/dti
#trac-all -bedp -c ${subj}_dmric.txt
bedpostx_gpu ${subj}/dmri
#echo $FSLDIR
