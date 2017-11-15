#!/bin/bash
#SBATCH -p gpu -N 1 -c 1 -t 24:00:00 --gres=gpu:k80:1 --gres-flags=enforce-binding --mem-per-cpu=16000
subj_list=$1
module load FSL/5.0.9-centos6_64
module load CUDA/6.5.14
source ${FSLDIR}/etc/fslconf/fsl.sh

cd ~/scratch60/pnc/dti
#trac-all -bedp -c ${subj}_dmric.txt
bedpostx_gpu ${subj}/dmri 

