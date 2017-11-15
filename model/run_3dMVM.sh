#!/bin/bash
#SBATCH -p general -N 1 -c 10 --mem-per-cpu=5000 -t 48:00:00 --mail-type=ALL --mail-user=chintan.mehta@yale.edu

dos2unix $2
wc -l $2
head $2
FN_MASK=~/project/code/masks/TT_N27_GM_3mm.nii

module load Python/2.7.11-foss-2016a
cd /ysm-gpfs/home/cm953/project/pnc/mri/subjects/
#pwd

3dMVM -prefix $1 -jobs 10 \
	-mask $FN_MASK \
	-bsVars "${3}" \
	-overwrite \
	-qVars "age,PE,PC1,PC2,PC3,PC4,PC5,PC6,SCZ_inf,SCZ_p0.10,EDU_inf,EDU_p0.10,AUT_inf,AUT_p0.10,EstimatedTotalIntraCranialVol,SCZ_p0.30,SCZ_p0.01,SCZ_p1.00" \
	-num_glt 2 \
	-dataTable @${2}

echo $FN_MASK


3dinfo -label ${1}+tlrc
3dinfo -max ${1}+tlrc

