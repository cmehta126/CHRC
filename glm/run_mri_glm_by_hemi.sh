#!/bin/bash
#SBATCH -N 1 -c 1 --mem-per-cpu=16000 -t 48:00:00 --mail-type=ALL --mail-user=chintan.mehta@yale.edu
HYP=$1; hemi=$2; meas=$3; fwhm=$4;

cd ~/project/fs_glm
#Y=a_${HYP}.lh.lh-rh.LI.${meas}.fsaverage_sym.fwhm${fwhm}.mgh
#x002_hemi.lh.area.fwhm5.fsaverage.mgh

Y=${HYP}_hemi.${hemi}.${meas}.fwhm${fwhm}.fsaverage.mgh

mri_glmfit --y ${Y} --X ${HYP}_design.txt --no-rescale-x --glmdir c_glm_hemi.${HYP}.${hemi}.${meas}.fwhm${fwhm} --C con_age1.mat --C con_PE_age1.mat --C con_TEX_age1.mat --C con_tiv.mat --C con_sex.mat --C con_intx.mat --C con_intx_PE.mat --C con_intx_TEX.mat --surf fsaverage $hemi 

glmDIR=c_glm_hemi.${HYP}.${hemi}.${meas}.fwhm${fwhm}
mri_glmfit-sim --glmdir $glmDIR --a2009s --cwpvalthresh .25 --3spaces --cache 2 pos
mri_glmfit-sim --glmdir $glmDIR --a2009s --cwpvalthresh .25 --3spaces --cache 3 pos

mri_glmfit-sim --glmdir $glmDIR --a2009s --cwpvalthresh .25 --3spaces --cache 2 abs
mri_glmfit-sim --glmdir $glmDIR --a2009s --cwpvalthresh .25 --3spaces --cache 3 abs




