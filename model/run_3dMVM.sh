#!/bin/bash
#SBATCH -p general -N 1 -c 20 --mem-per-cpu=5000 -t 48:00:00 --mail-type=ALL --mail-user=chintan.mehta@yale.edu

dos2unix $2
wc -l $2
head $2
FN_MASK=~/project/code/masks/TT_N27_GM_3mm.nii
3dMVM	-prefix $1 -jobs 20 -mask $FN_MASK -bsVars "${3}" -qVars "age,PE,wrat_cr_raw,wrat_cr_std,wrat_resid,pcpt_n_tp,EDU_inf,EDU_p0.10,SCZ_inf,SCZ_p0.10,AUT_inf,AUT_p0.10,PC1,PC2,PC3,PC4,PC5,PC6" -dataTable @${2}
echo $FN_MASK
