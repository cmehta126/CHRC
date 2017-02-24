#!/bin/bash
#SBATCH -p general -N 1 -c 1 --mem-per-cpu=5000 -t 48:00:00 --mail-type=ALL --mail-user=chintan.mehta@yale.edu

REST_PAR=$1
aSub=$2
FN_CLUSTER_MASK=$3
CLUSTER_MASK_NAME=$4

SUFFIX=${CLUSTER_MASK_NAME}.${aSub}.${REST_PAR}
FN_OUT=/ysm-gpfs/home/cm953/project/pnc/model/seed/${CLUSTER_MASK_NAME}/Zscore_seed.${SUFFIX}.nii.gz
FN_GM_MASK=/ysm-gpfs/home/cm953/project/code/masks/TT_N27_GM_3mm.nii

echo "Performing seed-based correlation for subject $aSub with mask ${CLUSTER_MASK_NAME} under resting state preprocessing parameters ${REST_PAR}."
echo "Cluster mask is located at $FN_CLUSTER_MASK."

cd ~/project/pnc/mri/subjects/${aSub}/${aSub}.${REST_PAR}
[ ! -d extra ] && mkdir extra

3dmaskave -quiet -mask $FN_CLUSTER_MASK errts.${aSub}.fanaticor+tlrc > extra/ts.${SUFFIX}.1D
echo "Created ideal file."

3dfim+ -input errts.${aSub}.fanaticor+tlrc -mask $FN_GM_MASK -ideal_file extra/ts.${SUFFIX}.1D -out Correlation -overwrite -bucket extra/Corr_seed.${SUFFIX}
echo "Created time series correlation map."
3dcalc -a extra/Corr_seed.${SUFFIX}+tlrc -expr 'atanh(a)' -float -overwrite -prefix $FN_OUT
echo "Fisher transformation of correlation map is in ${FN_OUT}."

echo "Complete."
