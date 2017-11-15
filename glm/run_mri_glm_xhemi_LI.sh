#!/bin/bash
#SBATCH -N 1 -c 1 --mem-per-cpu=16000 -t 48:00:00 --mail-type=ALL --mail-user=chintan.mehta@yale.edu
HYP=$1; meas=$2; fwhm=$3;

cd ~/project/fs_glm
Y=a_${HYP}.lh.lh-rh.LI.${meas}.fsaverage_sym.fwhm${fwhm}.mgh
mri_glmfit --y ${Y} --X ${HYP}_design.txt --no-rescale-x --glmdir b_glm_xhemi.${HYP}.${meas}.fwhm${fwhm} --C con_age1.mat --C con_PE_age1.mat --C con_TEX_age1.mat --C con_tiv.mat --C con_sex.mat --C con_intx.mat --C con_intx_PE.mat --C con_intx_TEX.mat --surf fsaverage_sym lh 
mri_glmfit-sim --glmdir  b_glm_xhemi.${HYP}.${meas}.fwhm${fwhm} --a2009s --cwpvalthresh .25 --3spaces --cache 2 pos
mri_glmfit-sim --glmdir  b_glm_xhemi.${HYP}.${meas}.fwhm${fwhm} --a2009s --cwpvalthresh .25 --3spaces --cache 3 pos
mri_glmfit-sim --glmdir  b_glm_xhemi.${HYP}.${meas}.fwhm${fwhm} --a2009s --cwpvalthresh .25 --3spaces --cache 2 abs
mri_glmfit-sim --glmdir  b_glm_xhemi.${HYP}.${meas}.fwhm${fwhm} --a2009s --cwpvalthresh .25 --3spaces --cache 3 abs




