#!/bin/bash
#SBATCH -N 1 -c 1 --mem-per-cpu=32000 -t 48:00:00 --mail-type=ALL --mail-user=chintan.mehta@yale.edu

HYP=$1
cd ~/project/fs_glm
mris_preproc --target fsaverage_sym --hemi lh --xhemi --paired-diff --srcsurfreg fsaverage_sym.sphere.reg --meas area --out  ${HYP}_lh.lh-rh.area.sm00.mgh --f ${HYP}_ids.txt 


