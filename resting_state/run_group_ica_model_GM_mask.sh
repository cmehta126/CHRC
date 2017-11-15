#!/usr/bin/bash
#SBATCH -p general -N 1 -c 10 --mem-per-cpu=6000 -t 48:00:00 --mail-type=ALL --mail-user=chintan.mehta@yale.edu

FN_DATA=$1
SUBBRICK=$2
MODEL_LABEL=$3
MODEL=$4
PWD_DATA=$5
PWD_RESULTS=$6

PREFIX=${PWD_RESULTS}/group.${MODEL_LABEL}.${SUBBRICK}
FN_WORKING=~/scratch60/ica/data/working_${MODEL_LABEL}.${SUBBRICK}.txt

echo $PREFIX

#dos2unix $FN_DATA
cp $FN_DATA $FN_WORKING
sed -i -- "s/XXXXX/${SUBBRICK}/g" $FN_WORKING
head -n 4 $FN_WORKING


FN_MASK=~/project/code/masks/TT_N27_GM_3mm.nii
cd $PWD_DATA
pwd

3dMVM -prefix $PREFIX -jobs 9 -mask $FN_MASK -bsVars "${MODEL}" -overwrite -qVars "age,PE,PC1,PC2,PC3,PC4,PC5,PC6,SCZ_inf,SCZ_p0.10,EDU_inf,EDU_p0.10,AUT_inf,AUT_p0.10,EstimatedTotalIntraCranialVol,SCZ_p0.30,SCZ_p0.01,SCZ_p1.00" -dataTable @${FN_WORKING}

3dinfo -label ${PREFIX}+tlrc
3dinfo -max ${PREFIX}+tlrc

#-num_glt 2 -gltLabel 1 PE -gltCode 1 "PE" -gltLabel 2 SCZ -gltCode 2 "SCZ_inf" 
