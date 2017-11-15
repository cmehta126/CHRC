#!/bin/bash
#SBATCH -p scavenge -N 1 -c 1 --mem-per-cpu=6000 -t 48:00:00 --mail-type=ALL --mail-user=chintan.mehta@yale.edu
module load FSL
SUB=$1
a=/ysm-gpfs/home/cm953/scratch60/data/dti_raw_data/${SUB}_DTI
b=$SUBJECTS_DIR/${SUB}/mri/dti
dt_recon --i ${a}.nii.gz --b ${a}.bval ${a}.bvec --s ${SUB} --o $b

