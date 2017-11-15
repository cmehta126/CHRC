#!/bin/bash
#SBATCH -p general -N 1 -c 18 --mem-per-cpu=5000 -t 48:00:00 --mail-type=ALL --mail-user=chintan.mehta@yale.edu

#dos2unix $2

FN_DATA=$1
SUBBRICK=$2
MODEL_LABEL=$3
MODEL=$4
PWD_DATA=$5
PWD_RESULTS=$6

PREFIX=${PWD_RESULTS}/group.${MODEL_LABEL}
FN_WORKING=~/scratch60/nback/data/working_nback_${MODEL_LABEL}.txt
cp $1 $FN_WORKING
#sed -i -- "s/XXXXX/${CONTRAST}/g" $FN_WORKING


FN_MASK=~/project/code/masks/TT_N27_3mm.nii

module load Python/2.7.11-foss-2016a
cd /ysm-gpfs/home/cm953/project/pnc/mri/subjects/
#pwd

3dMVM -prefix $PREFIX -jobs 18 -mask $FN_MASK -bsVars "${MODEL}" -overwrite -qVars "age,PE,PC1,PC2,PC3,PC4,PC5,PC6,SCZ_inf,SCZ_p0.10,EDU_inf,EDU_p0.10,AUT_inf,AUT_p0.10,EstimatedTotalIntraCranialVol,SCZ_p0.30,SCZ_p0.01,SCZ_p1.00" -num_glt 2 -gltLabel 1 PE -gltCode 1 "PE" -gltLabel 2 SCZ -gltCode 2 "SCZ_inf" -dataTable @${FN_WORKING}

3dinfo -label ${PREFIX}+tlrc
3dinfo -max ${PREFIX}+tlrc

